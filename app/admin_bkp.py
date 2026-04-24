# File: admin.py
# Location: /app/

import os
import json
from werkzeug.utils import secure_filename 
from werkzeug.security import generate_password_hash
from flask import Blueprint, render_template, session, redirect, url_for, flash, jsonify, request, current_app
from .db import get_db_connection

admin_bp = Blueprint('admin', __name__, url_prefix='/admin')

@admin_bp.before_request
def require_helpdesk_login():
    if not session.get('user_id'):
        return redirect(url_for('auth.login'))
    if session.get('user_type') not in ['helpdesk', 'admin']:
        flash('Unauthorized. Helpdesk access only.', 'error')
        return redirect(url_for('user.dashboard'))

@admin_bp.route('/')
@admin_bp.route('/dashboard')
def dashboard():
    connection = get_db_connection()
    stats = {"orders_today": 0, "active_orders": 0, "pending_exceptions": 0, "active_stores": 0}
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetGlobalAdminDashboardStats')
        
        for result in cursor.stored_results():
            fetched = result.fetchone()
            if fetched:
                stats = fetched
    except Exception as e:
        print(f"DEBUG [Admin Dashboard]: {e}")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

    return render_template('admin/dashboard_admin.html', stats=stats)

@admin_bp.route('/sales/orders')
def global_orders():
    connection = get_db_connection()
    orders = []
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetGlobalOrders')
        for result in cursor.stored_results():
            orders = result.fetchall()
            
        for order in orders:
            if order.get('created_at'):
                order['formatted_date'] = order['created_at'].strftime("%m/%d/%Y %I:%M %p")
    except Exception as e:
        print(f"DEBUG [Helpdesk Orders]: {e}")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

    return render_template('admin/global_orders.html', orders=orders)


@admin_bp.route('/exceptions')
def global_exceptions():
    """Helpdesk view for all pending warehouse short-picks across the network."""
    connection = get_db_connection()
    exceptions = []
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetGlobalPendingExceptions')
        for result in cursor.stored_results():
            exceptions = result.fetchall()
            
        for exc in exceptions:
            if exc.get('created_at'):
                exc['formatted_date'] = exc['created_at'].strftime("%m/%d/%Y %I:%M %p")
    except Exception as e:
        print(f"DEBUG [Global Exceptions]: {e}")
        flash("Failed to load global exceptions.", "error")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

    return render_template('admin/global_exceptions.html', exceptions=exceptions)

@admin_bp.route('/api/orders/<int:order_id>', methods=['GET'])
def get_order_details(order_id):
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetGlobalOrderDetails', [order_id])
        
        results = list(cursor.stored_results())
        order_header = results[0].fetchone() if len(results) > 0 else None
        order_items = results[1].fetchall() if len(results) > 1 else []
        exceptions = results[2].fetchall() if len(results) > 2 else []
        
        if not order_header:
            return jsonify({"error": "Order not found"}), 404
            
        return jsonify({
            "order": order_header,
            "items": order_items,
            "exceptions": exceptions
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@admin_bp.route('/api/orders/<int:order_id>/status', methods=['POST'])
def force_update_status(order_id):
    data = request.get_json()
    new_status = data.get('status')
    
    if not new_status:
        return jsonify({"error": "Status is required"}), 400
        
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('HelpdeskUpdateOrderStatus', [order_id, new_status])
        connection.commit()
        return jsonify({"success": True})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

# ==========================================
# MASTER CATALOG ROUTES
# ==========================================

@admin_bp.route('/catalog/products')
def catalog_list():
    connection = get_db_connection()
    products = []
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetAdminProducts')
        for result in cursor.stored_results():
            products = result.fetchall()
    except Exception as e:
        print(f"DEBUG [Admin Catalog]: {e}")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

    return render_template('admin/catalog_list.html', products=products)


@admin_bp.route('/catalog/products/edit/<int:product_id>')
def product_edit(product_id):
    connection = get_db_connection()
    categories, brands, stores = [], [], []
    
    # 1. Fetch Dependencies (Dropdowns)
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetAdminCatalogDependencies')
        results = list(cursor.stored_results())
        if len(results) > 0: categories = results[0].fetchall()
        if len(results) > 1: brands = results[1].fetchall()
        if len(results) > 2: stores = results[2].fetchall()
    except Exception as e:
        print(f"DEBUG [Deps]: {e}")
    finally:
        cursor.close()

    # 2. Fetch Product Edit Data
    edit_data = {
        "master": None, "variants": [], "variant_attrs": [], 
        "inventory": [], "media": [], "volume_pricing": []
    }
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetAdminProductEditData', [product_id])
        results = list(cursor.stored_results())
        
        if len(results) > 0: edit_data["master"] = results[0].fetchone()
        if len(results) > 1: edit_data["variants"] = results[1].fetchall()
        if len(results) > 2: edit_data["variant_attrs"] = results[2].fetchall()
        if len(results) > 3: edit_data["inventory"] = results[3].fetchall()
        if len(results) > 4: edit_data["media"] = results[4].fetchall()
        if len(results) > 5: edit_data["volume_pricing"] = results[5].fetchall()
        
        if not edit_data["master"]:
            flash("Product not found.", "error")
            return redirect(url_for('admin.catalog_list'))
            
    except Exception as e:
        print(f"DEBUG [Edit Data]: {e}")
        flash("Error loading product data.", "error")
        return redirect(url_for('admin.catalog_list'))
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

    return render_template('admin/product_edit.html', 
                           categories=categories, brands=brands, stores=stores,
                           edit_data=edit_data)

@admin_bp.route('/catalog/products/create')
def product_create():
    connection = get_db_connection()
    categories = []
    brands = []
    stores = []
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetAdminCatalogDependencies')
        results = list(cursor.stored_results())
        if len(results) > 0: categories = results[0].fetchall()
        if len(results) > 1: brands = results[1].fetchall()
        if len(results) > 2: stores = results[2].fetchall()
    except Exception as e:
        print(f"DEBUG [Admin Catalog Dependencies]: {e}")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

    return render_template('admin/product_create.html', categories=categories, brands=brands, stores=stores)

@admin_bp.route('/api/catalog/products', methods=['POST'])
def api_create_product():
    raw_data = request.form.get('product_data')
    if not raw_data:
        return jsonify({"error": "No product data provided."}), 400
        
    data = json.loads(raw_data)
    
    name = data.get('name')
    sku = data.get('sku')
    price = data.get('price')
    has_variants = data.get('has_variants', False)
    variants_data = data.get('variants', [])
    
    if not name or not sku or not price:
        return jsonify({"error": "Name, SKU, and Base Price are required."}), 400

    inv_json = None
    if not has_variants:
        inv_json = json.dumps(data.get('inventory', [])) if data.get('inventory') else None
        
    vol_json = json.dumps(data.get('volume_pricing', [])) if data.get('volume_pricing') else None

    old_price = data.get('old_price') or None
    product_cost = data.get('product_cost') or None
    disable_buy_button = 1 if data.get('disable_buy_button') else 0
    call_for_price = 1 if data.get('call_for_price') else 0
    weight = data.get('weight') or 0.00
    length = data.get('length') or 0.00
    width = data.get('width') or 0.00
    height = data.get('height') or 0.00
    min_qty = data.get('minimum_cart_qty') or 1
    max_qty = data.get('maximum_cart_qty') or 10000
    not_returnable = 1 if data.get('not_returnable') else 0
    
    is_published = 1 if data.get('is_published', True) else 0
    
    # NEW: Extract Case Pack
    case_pack = data.get('case_pack_quantity') or 1

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        
        # 1. Create Base Product
        cursor.callproc('CreateB2BProduct', [
            name, data.get('short_description', ''), data.get('full_description', ''),
            sku, data.get('category_id') or None, data.get('brand_id') or None,
            data.get('specifications', ''), data.get('warranty_info', ''), data.get('manufacturer_info', ''),
            price, inv_json, vol_json,
            data.get('gtin', ''), data.get('manufacturer_part_number', ''),
            old_price, product_cost, disable_buy_button, call_for_price,
            weight, length, width, height, min_qty, max_qty, not_returnable, data.get('admin_comment', ''),
            is_published, case_pack # ADDED CASE PACK
        ])
        
        new_sku_id = None
        for result in cursor.stored_results():
            row = result.fetchone()
            if row:
                if isinstance(row, dict) and 'new_product_id' in row:
                    new_sku_id = row['new_product_id']
                elif isinstance(row, (tuple, list)) and len(row) > 0:
                    new_sku_id = row[0]
            result.fetchall() 
                
        if not new_sku_id:
            raise Exception("Failed to generate Product ID")

        upload_dir = os.path.join(current_app.root_path, 'static', 'uploads', 'products')
        os.makedirs(upload_dir, exist_ok=True)

        # 2. Variant Generation & Variant Media Logic
        if has_variants and variants_data:
            print(f"DEBUG: Processing {len(variants_data)} variants for product {new_sku_id}")
            for v_index, var in enumerate(variants_data):
                combo_key = var.get('combination')
                v_sku = var.get('sku')
                v_price = var.get('price')
                
                cursor.callproc('CreateProductVariant', [new_sku_id, v_sku, v_price, combo_key])
                new_variant_id = None
                
                for result in cursor.stored_results():
                    v_row = result.fetchone()
                    if v_row:
                        if isinstance(v_row, dict) and 'new_variant_id' in v_row:
                            new_variant_id = v_row['new_variant_id']
                        elif isinstance(v_row, (tuple, list)) and len(v_row) > 0:
                            new_variant_id = v_row[0]
                    result.fetchall()
                        
                if new_variant_id:
                    for attr in var.get('attributes', []):
                        a_name = attr.get('name')
                        a_val = attr.get('value')
                        if a_name and a_val:
                            cursor.callproc('AddVariantAttribute', [new_variant_id, a_name, a_val])
                            for _res in cursor.stored_results(): _res.fetchall()

                    for inv_store in data.get('inventory', []):
                        store_id = inv_store.get('store_id')
                        v_stocks = inv_store.get('variant_stocks', {})
                        if combo_key in v_stocks:
                            v_qty = v_stocks[combo_key].get('quantity', 0)
                            v_thresh = v_stocks[combo_key].get('threshold', 0)
                            cursor.callproc('SetVariantInventory', [new_sku_id, new_variant_id, store_id, v_qty, v_thresh])
                            for _res in cursor.stored_results(): _res.fetchall()

                    v_media_files = request.files.getlist(f'variant_{v_index}_media')
                    for f_index, file in enumerate(v_media_files):
                        if file.filename:
                            is_primary = 1 if request.form.get(f'variant_{v_index}_is_primary_{f_index}') == '1' else 0
                            filename = f"sku_{new_sku_id}_var_{new_variant_id}_{secure_filename(file.filename)}"
                            file_path = os.path.join(upload_dir, filename)
                            file.save(file_path)
                            
                            media_type = 'video' if file.content_type.startswith('video') else 'image'
                            media_url = f'/static/uploads/products/{filename}'
                            
                            cursor.callproc('AddProductMedia', [new_sku_id, new_variant_id, media_type, media_url, f_index, is_primary])
                            for _res in cursor.stored_results(): _res.fetchall()

        # 3. Process Global Master Media Files
        media_files = request.files.getlist('media_files')
        for i, file in enumerate(media_files):
            if file.filename:
                is_primary = 1 if request.form.get(f'is_primary_{i}') == '1' else 0
                filename = f"sku_{new_sku_id}_master_{secure_filename(file.filename)}"
                file_path = os.path.join(upload_dir, filename)
                file.save(file_path)
                
                media_type = 'video' if file.content_type.startswith('video') else 'image'
                media_url = f'/static/uploads/products/{filename}'
                
                cursor.callproc('AddProductMedia', [new_sku_id, None, media_type, media_url, i, is_primary])
                for _res in cursor.stored_results(): _res.fetchall()
                
        connection.commit()
        return jsonify({"success": True, "product_id": new_sku_id})
        
    except Exception as e:
        print(f"DEBUG [Create Product]: {e}")
        error_msg = str(e)
        if "Duplicate entry" in error_msg and "sku" in error_msg:
            error_msg = "A product with this SKU already exists."
        return jsonify({"error": error_msg}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()


# --- ADD CATEGORY / BRAND DYNAMICALLY ---

@admin_bp.route('/catalog/categories')
def category_list():
    connection = get_db_connection()
    categories = []
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetCategoriesList')
        for result in cursor.stored_results():
            categories = result.fetchall()
    except Exception as e:
        print(f"DEBUG [Category List]: {e}")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()
    return render_template('admin/categories.html', categories=categories)

@admin_bp.route('/catalog/brands')
def brand_list():
    connection = get_db_connection()
    brands = []
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetBrandsList')
        for result in cursor.stored_results():
            brands = result.fetchall()
    except Exception as e:
        print(f"DEBUG [Brand List]: {e}")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()
    return render_template('admin/brands.html', brands=brands)

@admin_bp.route('/api/catalog/categories', methods=['POST'])
def api_create_category():
    data = request.get_json()
    name = data.get('name')
    description = data.get('description', '')
    
    if not name:
        return jsonify({"error": "Category name is required."}), 400

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('CreateCategory', [name, description])
        
        new_id = None
        for result in cursor.stored_results():
            row = result.fetchone()
            if row: 
                new_id = row['new_id']
                
        connection.commit()
        return jsonify({"success": True, "category_id": new_id, "name": name})
    except Exception as e:
        print(f"DEBUG [Create Category]: {e}")
        error_msg = str(e)
        if "Duplicate entry" in error_msg:
            error_msg = "A category with this name already exists."
        return jsonify({"error": error_msg}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@admin_bp.route('/api/catalog/brands', methods=['POST'])
def api_create_brand():
    data = request.get_json()
    name = data.get('name')
    description = data.get('description', '')
    
    if not name:
        return jsonify({"error": "Brand name is required."}), 400

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('CreateBrand', [name, description])
        
        new_id = None
        for result in cursor.stored_results():
            row = result.fetchone()
            if row: 
                new_id = row['new_id']
                
        connection.commit()
        return jsonify({"success": True, "brand_id": new_id, "name": name})
    except Exception as e:
        print(f"DEBUG [Create Brand]: {e}")
        error_msg = str(e)
        if "Duplicate entry" in error_msg:
            error_msg = "A brand with this name already exists."
        return jsonify({"error": error_msg}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

# ==========================================
# NEW: SUPPLY CHAIN NETWORK / LOCATIONS ROUTE
# ==========================================

@admin_bp.route('/network')
def network_management():
    """Loads the Region -> Area -> Store Management Page"""
    connection = get_db_connection()
    hierarchy = []
    
    try:
        cursor = connection.cursor(dictionary=True)
        # Re-using the SP that already builds the hierarchy structure for the user dropdowns
        cursor.callproc('GetStoreHierarchy')
        
        rows = []
        for result in cursor.stored_results():
            rows = result.fetchall()
            
        # Re-build the nested structure for Alpine.js consumption
        hierarchy_dict = {}
        for row in rows:
            r_id = row['region_id']
            if r_id not in hierarchy_dict:
                hierarchy_dict[r_id] = {'id': r_id, 'name': row['name'], 'areas': {}}
            
            a_id = row['area_id']
            if a_id and a_id not in hierarchy_dict[r_id]['areas']:
                hierarchy_dict[r_id]['areas'][a_id] = {'id': a_id, 'name': row['name'], 'stores': []}
                
            if a_id and row['store_id']:
                hierarchy_dict[r_id]['areas'][a_id]['stores'].append({
                    'id': row['store_id'],
                    'name': row['name'],
                    'code': row['store_code'],
                    'min_order_value': row.get('min_order_value', 0.0),
                    'max_order_value': row.get('max_order_value', 0.0),
                    'approval_thresholds': row.get('approval_thresholds', 0.0)
                })
                
        for r in hierarchy_dict.values():
            r['areas'] = list(r['areas'].values())
            hierarchy.append(r)
            
    except Exception as e:
        print(f"DEBUG [Network Management]: {e}")
        flash('Failed to load supply chain network.', 'error')
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

    return render_template('admin/network.html', hierarchy=hierarchy)


# Thin APIs for CRUD operations on Locations

@admin_bp.route('/api/network/region', methods=['POST', 'PUT'])
def api_save_region():
    data = request.get_json()
    name = data.get('name')
    region_id = data.get('id')
    
    if not name: return jsonify({"error": "Region name required"}), 400
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        if request.method == 'POST':
            cursor.callproc('CreateRegion', [name])
            res = cursor.stored_results()
            for r in res: region_id = r.fetchone()['new_id']
        else:
            cursor.callproc('UpdateRegion', [region_id, name])
            
        connection.commit()
        return jsonify({"success": True, "id": region_id, "name": name})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@admin_bp.route('/api/network/area', methods=['POST', 'PUT'])
def api_save_area():
    data = request.get_json()
    name = data.get('name')
    region_id = data.get('region_id')
    area_id = data.get('id')
    
    if not name: return jsonify({"error": "Area name required"}), 400
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        if request.method == 'POST':
            if not region_id: return jsonify({"error": "Region ID required"}), 400
            cursor.callproc('CreateArea', [region_id, name])
            res = cursor.stored_results()
            for r in res: area_id = r.fetchone()['new_id']
        else:
            cursor.callproc('UpdateArea', [area_id, name])
            
        connection.commit()
        return jsonify({"success": True, "id": area_id, "name": name})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@admin_bp.route('/api/network/store', methods=['POST', 'PUT'])
def api_save_store():
    data = request.get_json()
    name = data.get('name')
    code = data.get('code', '')
    area_id = data.get('area_id')
    store_id = data.get('id')
    
    # B2B Financial Rules
    min_order = data.get('min_order_value', 0.00)
    max_order = data.get('max_order_value', 999999.99)
    approval_threshold = data.get('approval_thresholds', 0.00)
    
    if not name: return jsonify({"error": "Store name required"}), 400
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        if request.method == 'POST':
            if not area_id: return jsonify({"error": "Area ID required"}), 400
            cursor.callproc('CreateStore', [area_id, name, code, min_order, max_order, approval_threshold])
            res = cursor.stored_results()
            for r in res: store_id = r.fetchone()['new_id']
        else:
            cursor.callproc('UpdateStore', [store_id, name, code, min_order, max_order, approval_threshold])
            
        connection.commit()
        return jsonify({"success": True, "id": store_id, "name": name, "code": code})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

# ==========================================
# PHASE 1: RESTAURANT (FACILITY) MANAGEMENT
# ==========================================

@admin_bp.route('/restaurants')
def manage_restaurants():
    """Loads the Master List of all Restaurant Facilities"""
    connection = get_db_connection()
    restaurants = []
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetAdminRestaurants')
        for res in cursor.stored_results():
            restaurants = res.fetchall()
            
    except Exception as e:
        print(f"DEBUG [Restaurants]: {e}")
        flash('Failed to load restaurants.', 'error')
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

    return render_template('admin/restaurants.html', restaurants=restaurants)

@admin_bp.route('/api/restaurants', methods=['POST', 'PUT'])
def api_save_restaurant():
    """Creates or Updates a Restaurant Facility"""
    data = request.get_json()
    
    restaurant_id = data.get('restaurant_id') # Will be None if POST
    name = data.get('restaurant_name')
    code = data.get('restaurant_code')
    address = data.get('address')
    city = data.get('city')
    state = data.get('state')
    zip_code = data.get('zip')

    if not name or not code:
        return jsonify({"error": "Restaurant Name and Restaurant Code are strictly required."}), 400

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        
        if request.method == 'POST':
            cursor.callproc('CreateRestaurantFacility', [
                name, code, address, city, state, zip_code
            ])
        else: # PUT request
            if not restaurant_id:
                return jsonify({"error": "Restaurant ID is missing for update."}), 400
            cursor.callproc('UpdateRestaurantFacility', [
                restaurant_id, name, code, address, city, state, zip_code
            ])
            
        connection.commit()
        return jsonify({"success": True})
    except Exception as e:
        error_msg = str(e)
        if "Duplicate entry" in error_msg:
            error_msg = "A facility with this Restaurant Code already exists."
        return jsonify({"error": error_msg}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

# PHASE 2: USER PROVISIONING & TAGGING
# ==========================================
# SYSTEM USERS & ACCESS MANAGEMENT
# ==========================================

@admin_bp.route('/staff')
def manage_staff():
    """Loads the System Users Management Page"""
    connection = get_db_connection()
    users = []
    restaurants = []
    
    try:
        cursor = connection.cursor(dictionary=True)
        
        # 1. Fetch all system users and their mapped restaurants
        cursor.callproc('GetSystemUsers')
        for res in cursor.stored_results():
            users = res.fetchall()
            
        # 2. Fetch restaurants to populate the modal's dropdown
        cursor.callproc('GetAdminRestaurants')
        for res in cursor.stored_results():
            restaurants = res.fetchall()
            
    except Exception as e:
        print(f"DEBUG [Staff]: {e}")
        flash('Failed to load users.', 'error')
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

    return render_template('admin/users.html', users=users, restaurants=restaurants)


@admin_bp.route('/api/staff', methods=['POST', 'PUT'])
def api_save_staff():
    """Creates or Updates a System User & Tags to Restaurant"""
    data = request.get_json()
    
    user_id = data.get('user_id') # Will be None for new creations
    first_name = data.get('first_name')
    last_name = data.get('last_name', '')
    email = data.get('email')
    password = data.get('password')
    user_type = data.get('user_type')
    restaurant_id = data.get('restaurant_id')

    # Basic Validation
    if not first_name or not email or not user_type:
        return jsonify({"error": "First Name, Email, and Access Role are required."}), 400

    if request.method == 'POST' and not password:
        return jsonify({'error': 'A password is required for new users.'}), 400

    # Ensure Restaurant Tag is provided if they are a franchisee
    if user_type == 'restaurant' and not restaurant_id:
        return jsonify({"error": "You must select a Restaurant facility to tag this user to."}), 400
        
    # Security: Hash the password before sending to DB. 
    # If editing and password is blank, pass None so the DB ignores it.
    hashed_password = None
    if password:
        hashed_password = generate_password_hash(password)

    # Clean up the restaurant_id if the user is NOT a restaurant franchisee
    if user_type != 'restaurant':
        restaurant_id = None
    elif restaurant_id:
        restaurant_id = int(restaurant_id)

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        # We use the same Stored Procedure for both Creation and Edits
        cursor.callproc('SaveSystemUser', [
            user_id, 
            first_name, 
            last_name, 
            email, 
            hashed_password, 
            user_type, 
            restaurant_id
        ])
        connection.commit()
        return jsonify({"success": True})
        
    except Exception as e:
        error_msg = str(e)
        # Friendly error for duplicate emails
        if "Duplicate entry" in error_msg and "email" in error_msg.lower():
            error_msg = "An account with this email address already exists."
            
        return jsonify({"error": error_msg}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()