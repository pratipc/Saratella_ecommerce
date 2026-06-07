# File: admin.py
# Location: /app/

import os
import csv
import io
import json
from werkzeug.utils import secure_filename 
from werkzeug.security import generate_password_hash
from flask import Blueprint, render_template, session, redirect, url_for, flash, jsonify, request, current_app, Response
import time
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

# ==========================================
# PHASE 3: GLOBAL ORDER ROUTING (DOM)
# ==========================================

@admin_bp.route('/global-orders')
def global_orders():
    """Master View of All Orders across the network"""
    connection = get_db_connection()
    orders = []
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetAllGlobalOrders')
        for result in cursor.stored_results():
            orders = result.fetchall()
            
        # Format dates for Jinja
        for o in orders:
            if o.get('created_at'):
                o['formatted_date'] = o['created_at'].strftime("%b %d, %Y %I:%M %p")
                
    except Exception as e:
        print(f"DEBUG [Global Orders]: {e}")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

    return render_template('admin/global_orders.html', orders=orders)


@admin_bp.route('/orders/routing/<int:order_id>')
def route_order(order_id):
    """Interactive UI to split and assign fulfillments to specific warehouses"""
    connection = get_db_connection()
    order_header = None
    items = []
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetOrderRoutingDetails', [order_id])
        
        results = list(cursor.stored_results())
        if results:
            order_header = results[0].fetchone()
        if len(results) > 1:
            items = results[1].fetchall()
            
        if not order_header:
            flash("Order not found.", "error")
            return redirect(url_for('admin.global_orders'))
            
    except Exception as e:
        print(f"DEBUG [Route Order]: {e}")
        flash("Failed to load order routing details.", "error")
        return redirect(url_for('admin.global_orders'))
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

    return render_template('admin/order_routing_detail.html', order=order_header, items=items)


@admin_bp.route('/api/orders/<int:order_id>/allocate', methods=['POST'])
def api_allocate_order(order_id):
    """Processes the splits and deducts from physical warehouse inventory"""
    data = request.get_json()
    allocations = data.get('allocations', [])
    
    if not allocations:
        return jsonify({"error": "No routing plan provided."}), 400

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        
        # 1. Loop through each split/allocation and deduct inventory
        for alloc in allocations:
            item_id = alloc.get('order_item_id')
            store_id = alloc.get('store_id')
            qty = alloc.get('qty')
            
            if item_id and store_id and qty and int(qty) > 0:
                cursor.callproc('AllocateOrderItem', [order_id, item_id, store_id, qty])
        
        # 2. Update order status to processing
        cursor.callproc('MarkOrderProcessing', [order_id])
        
        connection.commit()
        return jsonify({"success": True})
        
    except Exception as e:
        print(f"DEBUG [API Allocation]: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()


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

@admin_bp.route('/api/orders/<int:order_id>/force-status', methods=['POST'])
def api_force_order_status(order_id):
    """Allows Admin/Helpdesk to manually override an order's status (Legacy/Exception bypass)"""
    if session.get('user_type') not in ['admin', 'helpdesk']:
        return jsonify({"error": "Unauthorized"}), 403

    data = request.get_json()
    new_status = data.get('status')
    admin_id = session.get('user_id')

    if not new_status:
        return jsonify({"error": "New status is required"}), 400

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('AdminForceUpdateOrderStatus', [order_id, new_status, admin_id])
        connection.commit()
        return jsonify({"success": True})
    except Exception as e:
        print(f"DEBUG [Admin Override]: {e}")
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


@admin_bp.route('/catalog/products/edit/<int:product_id>')
def edit_product(product_id):
    if session.get('user_type') not in ['admin', 'helpdesk']:
        flash('Unauthorized Access', 'error')
        return redirect(url_for('admin.dashboard'))

    connection = get_db_connection()
    product = None
    variants = []
    categories = []
    brands = []

    try:
        cursor = connection.cursor(dictionary=True)
        
        # 1. Fetch Categories & Brands for the dropdowns
        cursor.callproc('GetCategoriesList')
        for result in cursor.stored_results():
            categories = result.fetchall()
            
        cursor.callproc('GetBrandsList')
        for result in cursor.stored_results():
            brands = result.fetchall()

        # 2. Fetch the Product and its Variants
        cursor.callproc('GetAdminProductForEdit', [product_id])
        results = list(cursor.stored_results())
        
        if len(results) > 0:
            product = results[0].fetchone()
        if len(results) > 1:
            variants = results[1].fetchall()

        if not product:
            flash('Product not found.', 'error')
            return redirect(url_for('admin.catalog_list'))

    except Exception as e:
        print(f"DEBUG [Edit Product Load]: {e}")
        flash('Failed to load product details.', 'error')
        return redirect(url_for('admin.catalog_list'))
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

    return render_template('admin/product_edit.html', 
                           product=product, 
                           variants=variants, 
                           categories=categories, 
                           brands=brands)


@admin_bp.route('/api/catalog/products/<int:product_id>', methods=['PUT'])
def api_update_product(product_id):
    if session.get('user_type') not in ['admin', 'helpdesk']:
        return jsonify({"error": "Unauthorized"}), 403

    # Use form.get('data') because the frontend is now sending FormData to support image uploads
    raw_data = request.form.get('data')
    if not raw_data:
        return jsonify({"error": "Missing payload"}), 400
        
    data = json.loads(raw_data)
    
    # Safely cast values
    def safe_float(v, default=0.0):
        try: return float(v) if v != '' else default
        except: return default
    def safe_int(v, default=0):
        try: return int(v) if v != '' else default
        except: return default

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        
        # 1. Update Massive Product Header (Basic Info + B2B + Logistics)
        cursor.callproc('UpdateAdminProductHeader', [
            product_id, data.get('name'), data.get('sku'), safe_float(data.get('price')), 
            safe_int(data.get('category_id')), safe_int(data.get('brand_id')), 
            data.get('gtin', ''), data.get('manufacturer_part_number', ''), 
            data.get('description', ''), data.get('full_description', ''), data.get('admin_comment', ''),
            safe_float(data.get('old_price')), safe_float(data.get('product_cost')),
            1 if data.get('disable_buy_button') else 0, 1 if data.get('call_for_price') else 0,
            1 if data.get('not_returnable') else 0, safe_float(data.get('weight')), safe_float(data.get('length')),
            safe_float(data.get('width')), safe_float(data.get('height')),
            safe_int(data.get('case_pack_quantity'), 1), safe_int(data.get('minimum_cart_qty'), 1), safe_int(data.get('maximum_cart_qty'), 10000),
            data.get('specifications', ''), data.get('warranty_info', ''), data.get('manufacturer_info', ''),
            1 if data.get('is_active') else 0
        ])

        # 2. Variant Shifting Logic
        if not data.get('has_variants'):
            cursor.callproc('ClearProductVariants', [product_id])
        else:
            for del_id in data.get('deleted_variants', []):
                cursor.callproc('DeleteSingleVariant', [product_id, del_id])
            for v in data.get('variants', []):
                if v.get('sku') and v.get('name'): 
                    cursor.callproc('UpsertProductVariant', [
                        product_id, v.get('id') or 0, v.get('sku'), safe_float(v.get('price', data.get('price'))), v.get('name')
                    ])

        # 3. Save Volume Pricing
        cursor.callproc('SyncVolumePricing', [product_id, json.dumps(data.get('volume_pricing', []))])

        # 4. Save Inventory Distribution
        for inv in data.get('inventory', []):
            if not data.get('has_variants'):
                cursor.callproc('UpsertInventoryByCombo', [product_id, None, inv.get('store_id'), safe_int(inv.get('quantity')), safe_int(inv.get('threshold'))])
            else:
                for combo_key, stock_data in inv.get('variant_stocks', {}).items():
                    cursor.callproc('UpsertInventoryByCombo', [product_id, combo_key, inv.get('store_id'), safe_int(stock_data.get('quantity')), safe_int(stock_data.get('threshold'))])

        # 5. ======== MEDIA ENGINE UPLOAD LOGIC ========
        for m_id in data.get('deleted_media', []):
            cursor.callproc('DeleteProductMedia', [m_id])
            
        upload_folder = os.path.join('app', 'static', 'uploads', 'products')
        os.makedirs(upload_folder, exist_ok=True)
        
        def save_file(file_obj):
            if file_obj:
                filename = f"{int(time.time())}_{secure_filename(file_obj.filename)}"
                file_obj.save(os.path.join(upload_folder, filename))
                return f"/static/uploads/products/{filename}"
            return None

        # 5A. Global Product Media
        for meta in data.get('global_media_meta', []):
            if 'id' in meta:
                cursor.callproc('UpdateProductMediaPrimary', [meta['id'], 1 if meta['is_primary'] else 0])
            else:
                url = save_file(request.files.get(meta['key']))
                if url: cursor.callproc('AddProductMedia', [product_id, None, url, meta.get('type', 'image'), 1 if meta['is_primary'] else 0])

        # 5B. Variant Specific Media (FIXED: Uses Stored Procedure now)
        for meta in data.get('variant_media_meta', []):
            if 'id' in meta:
                cursor.callproc('UpdateProductMediaPrimary', [meta['id'], 1 if meta['is_primary'] else 0])
            else:
                url = save_file(request.files.get(meta['key']))
                if url:
                    # Clean Stored Procedure call instead of inline query
                    cursor.callproc('AddProductMediaByCombo', [
                        product_id, 
                        meta['variant_combo'], 
                        url, 
                        meta.get('type', 'image'), 
                        1 if meta['is_primary'] else 0
                    ])

        cursor.callproc('SyncProductPrimaryImage', [product_id])
        connection.commit()
        return jsonify({"success": True})
        
    except Exception as e:
        print(f"DEBUG [Update Product API]: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@admin_bp.route('/api/catalog/bulk-upload', methods=['POST'])
def api_bulk_upload_catalog():
    if session.get('user_type') not in ['admin', 'helpdesk']:
        return jsonify({"error": "Unauthorized"}), 403
        
    if 'file' not in request.files:
        return jsonify({"error": "No file uploaded. Please select a file."}), 400
        
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No file selected."}), 400
        
    if not file.filename.lower().endswith('.csv'):
        return jsonify({"error": "Please upload a .csv file for bulk import."}), 400
        
    connection = get_db_connection()
    success_count = 0
    failed_count = 0
    errors = []
    
    try:
        # Bulletproof reading of file to handle standard UTF-8 and Windows Excel exports
        file_bytes = file.stream.read()
        try:
            file_text = file_bytes.decode('utf-8-sig')
        except UnicodeDecodeError:
            file_text = file_bytes.decode('cp1252', errors='replace')
            
        stream = io.StringIO(file_text, newline=None)
        csv_input = csv.DictReader(stream)
        
        # Normalize headers
        if csv_input.fieldnames:
            csv_input.fieldnames = [str(f).strip() for f in csv_input.fieldnames]
            
        cursor = connection.cursor(dictionary=True)
        row_num = 1
        
        # Type casting safeguards
        def safe_float(val, default=0.0):
            try: return float(val) if val else default
            except: return default
            
        def safe_int(val, default=0):
            try: return int(val) if val else default
            except: return default
            
        def safe_bool(val, default=0):
            if not val: return default
            v = str(val).strip().lower()
            return 1 if v in ['1', 'yes', 'y', 'true', 't'] else 0

        for row in csv_input:
            row_num += 1
            cleaned_row = {str(k).strip(): str(v).strip() for k, v in row.items() if k and v is not None}
            
            name = cleaned_row.get('ProductName')
            base_sku = cleaned_row.get('BaseSKU')
            
            if not name or not base_sku:
                failed_count += 1
                errors.append(f"Row {row_num}: Missing ProductName or BaseSKU")
                continue
                
            # Extract Base Fields
            price = safe_float(cleaned_row.get('BasePrice'))
            old_price = safe_float(cleaned_row.get('OldPrice'))
            cost = safe_float(cleaned_row.get('ProductCost'))
            category = cleaned_row.get('Category', '')
            brand = cleaned_row.get('Brand', '')
            gtin = cleaned_row.get('GTIN', '')
            mpn = cleaned_row.get('MPN', '')
            weight = safe_float(cleaned_row.get('Weight'))
            length = safe_float(cleaned_row.get('Length'))
            width = safe_float(cleaned_row.get('Width'))
            height = safe_float(cleaned_row.get('Height'))
            case_pack = safe_int(cleaned_row.get('CasePack'), 1)
            min_cart = safe_int(cleaned_row.get('MinCart'), 1)
            max_cart = safe_int(cleaned_row.get('MaxCart'), 10000)
            
            # Extract Logistics/Rules
            non_returnable = safe_bool(cleaned_row.get('NonReturnable'))
            disable_buy = safe_bool(cleaned_row.get('DisableBuy'))
            call_price = safe_bool(cleaned_row.get('CallForPrice'))
            desc = cleaned_row.get('ShortDesc', '')
            full_desc = cleaned_row.get('FullDesc', '')
            admin_comment = cleaned_row.get('AdminComment', '')
            specs = cleaned_row.get('Specifications', '')
            warranty = cleaned_row.get('Warranty', '')
            mfg_info = cleaned_row.get('MfgInfo', '')
            active = safe_bool(cleaned_row.get('Active'), 1)
            
            # Extract Variant Fields & Media
            var_name = cleaned_row.get('VariantName', '')
            var_sku = cleaned_row.get('VariantSKU', '')
            var_price = safe_float(cleaned_row.get('VariantPrice', price))
            base_image_url = cleaned_row.get('ImageURL', '')
            var_image_url = cleaned_row.get('VariantImageURL', '')
            
            try:
                # 1. Upsert Base Product Information
                cursor.callproc('BulkImportProduct', [
                    name, base_sku, price, old_price, cost, category, brand, gtin, mpn,
                    weight, length, width, height, case_pack, min_cart, max_cart,
                    non_returnable, disable_buy, call_price, desc, full_desc, admin_comment,
                    specs, warranty, mfg_info, active
                ])
                
                base_sku_id = None
                for res in cursor.stored_results():
                    base_sku_id = res.fetchone()['new_id']
                    
                if not base_sku_id:
                    raise Exception("Failed to retrieve master Product ID from database")
                    
                # 2. Attach Global Product Image
                if base_image_url:
                    cursor.callproc('CheckMediaExists', [base_sku_id, None, base_image_url])
                    base_media_exists = False
                    for res in cursor.stored_results():
                        if res.fetchone():
                            base_media_exists = True
                            
                    if not base_media_exists:
                        cursor.callproc('AddProductMediaByCombo', [base_sku_id, None, base_image_url, 'image', 1])
                        cursor.callproc('SyncProductPrimaryImage', [base_sku_id])
                    
                # 3. Upsert Variant Details & Attributes
                if var_name and var_sku:
                    # Fetch existing variant ID using a stored proc
                    cursor.callproc('GetVariantIdBySku', [base_sku_id, var_sku])
                    var_row = None
                    for res in cursor.stored_results():
                        var_row = res.fetchone()
                        
                    var_id = var_row['variant_id'] if var_row else 0
                    
                    # Safe Upsert using the existing procedure
                    cursor.callproc('UpsertProductVariant', [
                        base_sku_id, var_id, var_sku, var_price, var_name
                    ])
                    
                    # Re-fetch the variant ID to securely assign attributes and images
                    cursor.callproc('GetVariantIdByCombo', [base_sku_id, var_name])
                    v_res = None
                    for res in cursor.stored_results():
                        v_res = res.fetchone()
                        
                    if v_res:
                        new_v_id = v_res['variant_id']
                        
                        # NEW: Parse and map attributes automatically based on template string!
                        # e.g., "Size - Small, Color - Red" gets parsed and assigned
                        attr_pairs = [pair.strip() for pair in var_name.split(',')]
                        for pair in attr_pairs:
                            if ' - ' in pair:
                                a_name, a_val = pair.split(' - ', 1)
                                cursor.callproc('AssignVariantAttribute', [new_v_id, a_name.strip(), a_val.strip()])
                        
                        # 4. Attach Variant Image
                        if var_image_url:
                            cursor.callproc('CheckMediaExists', [base_sku_id, new_v_id, var_image_url])
                            v_media_exists = False
                            for res in cursor.stored_results():
                                if res.fetchone():
                                    v_media_exists = True
                                    
                            if not v_media_exists:
                                cursor.callproc('AddProductMediaByCombo', [base_sku_id, var_name, var_image_url, 'image', 1])

                success_count += 1
            except Exception as e:
                failed_count += 1
                errors.append(f"Row {row_num}: {str(e)}")
                
        connection.commit()
        
        return jsonify({
            "success_count": success_count,
            "failed_count": failed_count,
            "errors": errors[:15] # Display top 15 errors in the UI
        })
        
    except Exception as e:
        print(f"DEBUG [Catalog Bulk Upload]: {e}")
        # ACID Compliance: Undo any partial saves if the whole file crashes!
        if connection and connection.is_connected():
            connection.rollback()
        return jsonify({"error": "Failed to parse file. Please ensure it is a valid CSV format."}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@admin_bp.route('/api/catalog/template')
def download_catalog_template():
    """Generates a smart CSV template pre-filled with Examples of Simple and Variant products."""
    if session.get('user_type') not in ['admin', 'helpdesk']:
        return jsonify({"error": "Unauthorized"}), 403
        
    output = io.StringIO()
    writer = csv.writer(output)
    
    headers = [
        'ProductName', 'BaseSKU', 'BasePrice', 'OldPrice', 'ProductCost', 
        'Category', 'Brand', 'GTIN', 'MPN', 'Weight', 'Length', 'Width', 'Height', 
        'CasePack', 'MinCart', 'MaxCart', 'NonReturnable', 'DisableBuy', 'CallForPrice', 
        'ShortDesc', 'FullDesc', 'AdminComment', 'Specifications', 'Warranty', 'MfgInfo', 'Active', 
        'VariantName', 'VariantSKU', 'VariantPrice', 'ImageURL', 'VariantImageURL'
    ]
    writer.writerow(headers)
    
    # Example 1: Standard Simple Product
    writer.writerow([
        'Signature Blend Coffee', 'COF-100', '15.99', '19.99', '8.00', 
        'Beverages', 'CafeBrand', '123456789012', 'CB-01', '1.0', '5.0', '4.0', '8.0', 
        '12', '1', '100', '0', '0', '0', 
        'Premium roasted beans.', 'Imported directly from Columbia. Best served black.', 'Seasonal item',
        'Roast: Dark\nOrigin: Columbia', '1 Year guarantee', 'Imported by CafeBrand LLC', '1', 
        '', '', '', 'https://example.com/coffee.jpg', '' # Notice variant columns are blank
    ])
    
    # Example 2: Variant Product (Row 1 - Small)
    writer.writerow([
        'Barista Apron', 'APR-200', '24.99', '29.99', '12.00', 
        'Apparel', 'CafeBrand', '', '', '0.5', '10.0', '10.0', '1.0', 
        '1', '1', '50', '0', '0', '0', 
        'Durable canvas apron.', '', '', 'Material: Canvas', '', '', '1', 
        'Size - Small', 'APR-200-S', '24.99', 'https://example.com/apron.jpg', 'https://example.com/apron-small.jpg'
    ])
    
    # Example 3: Variant Product (Row 2 - Large, shares same BaseSKU as above)
    writer.writerow([
        'Barista Apron', 'APR-200', '24.99', '29.99', '12.00', 
        'Apparel', 'CafeBrand', '', '', '0.5', '10.0', '10.0', '1.0', 
        '1', '1', '50', '0', '0', '0', 
        'Durable canvas apron.', '', '', 'Material: Canvas', '', '', '1', 
        'Size - Large', 'APR-200-L', '26.99', 'https://example.com/apron.jpg', 'https://example.com/apron-large.jpg'
    ])
    
    return Response(
        output.getvalue(),
        mimetype="text/csv",
        headers={"Content-disposition": "attachment; filename=catalog_import_template.csv"}
    )



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

@admin_bp.route('/api/catalog/categories', methods=['POST', 'PUT'])
def api_save_category():
    if session.get('user_type') not in ['admin', 'helpdesk']:
        return jsonify({"error": "Unauthorized"}), 403

    category_id = request.form.get('category_id')
    name = request.form.get('name')
    description = request.form.get('description', '')
    
    if not name:
        return jsonify({"error": "Category name is required."}), 400

    # Process and save the uploaded image
    image_url = None
    if 'image' in request.files:
        file = request.files['image']
        if file and file.filename != '':
            # THE FIX: Use current_app.static_folder to guarantee the exact correct system path!
            upload_folder = os.path.join(current_app.static_folder, 'uploads', 'categories')
            os.makedirs(upload_folder, exist_ok=True)
            
            filename = f"{int(time.time())}_{secure_filename(file.filename)}"
            file.save(os.path.join(upload_folder, filename))
            
            # The URL remains the same for the browser
            image_url = f"/static/uploads/categories/{filename}"

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        
        if request.method == 'POST':
            # Create New Category
            cursor.callproc('CreateCategory', [name, description, image_url])
            new_id = None
            for result in cursor.stored_results():
                row = result.fetchone()
                if row: 
                    new_id = row['new_id']
            connection.commit()
            return jsonify({"success": True, "category_id": new_id, "name": name})
            
        else:
            # Update Existing Category (PUT)
            if not category_id:
                return jsonify({"error": "Category ID is required for update."}), 400
                
            cursor.callproc('UpdateCategory', [category_id, name, description, image_url])
            connection.commit()
            return jsonify({"success": True, "category_id": category_id, "name": name})
            
    except Exception as e:
        print(f"DEBUG [Save Category]: {e}")
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
    if session.get('user_type') not in ['admin', 'helpdesk']:
        flash('Unauthorized Access', 'error')
        return redirect(url_for('admin.dashboard'))
        
    connection = get_db_connection()
    hierarchy = []
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetStoreHierarchy')
        rows = []
        for result in cursor.stored_results():
            rows = result.fetchall()
        
        # Build the exact hierarchy the Alpine.js frontend expects
        hierarchy_dict = {}
        for r in rows:
            r_id = r['region_id']
            if r_id not in hierarchy_dict:
                hierarchy_dict[r_id] = {
                    'id': r_id, 'name': r['region_name'], 'areas': {}
                }
            
            a_id = r['area_id']
            if a_id:
                if a_id not in hierarchy_dict[r_id]['areas']:
                    hierarchy_dict[r_id]['areas'][a_id] = {
                        'id': a_id, 'name': r['area_name'], 'stores': []
                    }
                
                s_id = r['store_id']
                if s_id:
                    hierarchy_dict[r_id]['areas'][a_id]['stores'].append({
                        'id': s_id,
                        'name': r['store_name'],
                        'code': r['store_code'],
                        'min_order_value': float(r['min_order_value'] or 0),
                        'max_order_value': float(r['max_order_value'] or 0),
                        'approval_threshold': float(r['approval_threshold'] or 0)
                    })
        
        # Convert dicts back to lists
        for r_id, r_data in hierarchy_dict.items():
            r_data['areas'] = list(r_data['areas'].values())
            hierarchy.append(r_data)
            
    except Exception as e:
        print(f"DEBUG [Hierarchy Builder]: {e}")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

    return render_template('admin/network.html', hierarchy=hierarchy)


@admin_bp.route('/api/network/region', methods=['POST', 'PUT'])
def api_save_region():
    if session.get('user_type') not in ['admin', 'helpdesk']: return jsonify({"error": "Unauthorized"}), 403
    data = request.get_json()
    name = data.get('name')
    region_id = data.get('id')
    
    if not name: return jsonify({"error": "Region name required"}), 400
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        if request.method == 'POST':
            cursor.callproc('CreateRegion', [name])
            for r in cursor.stored_results(): region_id = r.fetchone()['new_id']
        else:
            cursor.callproc('UpdateRegion', [region_id, name])
            
        connection.commit()
        return jsonify({"success": True, "id": region_id, "name": name})
    except Exception as e:
        print(f"DEBUG [Save Region]: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@admin_bp.route('/api/network/area', methods=['POST', 'PUT'])
def api_save_area():
    if session.get('user_type') not in ['admin', 'helpdesk']: return jsonify({"error": "Unauthorized"}), 403
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
            for r in cursor.stored_results(): area_id = r.fetchone()['new_id']
        else:
            cursor.callproc('UpdateArea', [area_id, name])
            
        connection.commit()
        return jsonify({"success": True, "id": area_id, "name": name})
    except Exception as e:
        print(f"DEBUG [Save Area]: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@admin_bp.route('/api/network/store', methods=['POST', 'PUT'])
def api_save_store():
    if session.get('user_type') not in ['admin', 'helpdesk']: return jsonify({"error": "Unauthorized"}), 403
    data = request.get_json()
    name = data.get('name')
    code = data.get('code', '')
    area_id = data.get('area_id')
    store_id = data.get('id')
    
    min_order = data.get('min_order_value', 0.00)
    max_order = data.get('max_order_value', 999999.99)
    approval_threshold = data.get('approval_threshold', 0.00) # Mapped correctly to match frontend
    
    if not name: return jsonify({"error": "Store name required"}), 400
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        if request.method == 'POST':
            if not area_id: return jsonify({"error": "Area ID required"}), 400
            cursor.callproc('CreateStore', [area_id, name, code, min_order, max_order, approval_threshold])
            for r in cursor.stored_results(): store_id = r.fetchone()['new_id']
        else:
            cursor.callproc('UpdateStore', [store_id, name, code, min_order, max_order, approval_threshold])
            
        connection.commit()
        return jsonify({"success": True, "id": store_id, "name": name, "code": code})
    except Exception as e:
        print(f"DEBUG [Save Store]: {e}")
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
    tax_rate = float(data.get('tax_rate', 0.00))

    if not name or not code:
        return jsonify({"error": "Restaurant Name and Restaurant Code are strictly required."}), 400

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        
        if request.method == 'POST':
            cursor.callproc('CreateRestaurantFacility', [
                name, code, address, city, state, zip_code, tax_rate
            ])
        else: # PUT request
            if not restaurant_id:
                return jsonify({"error": "Restaurant ID is missing for update."}), 400
            cursor.callproc('UpdateRestaurantFacility', [
                restaurant_id, name, code, address, city, state, zip_code, tax_rate
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

@admin_bp.route('/api/restaurants/bulk-upload', methods=['POST'])
def api_bulk_upload_restaurants():
    """Reads a CSV, iterates rows, and bulk-inserts restaurants."""
    if session.get('user_type') not in ['admin', 'helpdesk']:
        return jsonify({"error": "Unauthorized"}), 403
        
    if 'file' not in request.files:
        return jsonify({"error": "No file uploaded. Please select a file."}), 400
        
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No file selected."}), 400
        
    if not file.filename.lower().endswith('.csv'):
        return jsonify({"error": "Please upload a .csv file for bulk import."}), 400
        
    connection = get_db_connection()
    success_count = 0
    failed_count = 0
    errors = []
    
    try:
        # Bulletproof reading of file to handle standard UTF-8 and Windows Excel exports
        file_bytes = file.stream.read()
        try:
            # utf-8-sig automatically removes the hidden \ufeff BOM if present
            file_text = file_bytes.decode('utf-8-sig')
        except UnicodeDecodeError:
            # Fallback for old Windows Excel CSVs
            file_text = file_bytes.decode('cp1252', errors='replace')
            
        stream = io.StringIO(file_text, newline=None)
        csv_input = csv.DictReader(stream)
        
        # Normalize headers by stripping whitespace
        if csv_input.fieldnames:
            csv_input.fieldnames = [str(f).strip() for f in csv_input.fieldnames]
            
        def safe_float(val, default=0.0):
            try: return float(str(val).replace('%', '').strip()) if val else default
            except: return default
        
        cursor = connection.cursor()
        row_num = 1
        
        for row in csv_input:
            row_num += 1
            # Clean whitespace from keys and values
            cleaned_row = {str(k).strip(): str(v).strip() for k, v in row.items() if k and v is not None}
            
            # Smart mapping: Handles BOTH Standard Template & Chipotle Template headers
            name = cleaned_row.get('Restaurant Name') or cleaned_row.get('RestaurantName')
            code = cleaned_row.get('CHP Rest Number') or cleaned_row.get('RestaurantCode')
            address = cleaned_row.get('Address', '')
            city = cleaned_row.get('City', '')
            state = cleaned_row.get('State', '')
            zip_code = cleaned_row.get('Zipcode') or cleaned_row.get('Zip', '')
            tax_rate = safe_float(cleaned_row.get('Sales Tax %') or cleaned_row.get('Tax Rate') or cleaned_row.get('TaxRate'), 0.00)
            
            if not name or not code:
                failed_count += 1
                errors.append(f"Row {row_num}: Missing RestaurantName or RestaurantCode")
                continue
                
            try:
                cursor.callproc('CreateRestaurantFacility', [
                    name, code, address, city, state, zip_code, tax_rate
                ])
                success_count += 1
            except Exception as e:
                failed_count += 1
                error_msg = str(e)
                if "Duplicate" in error_msg:
                    error_msg = f"Code '{code}' already exists."
                errors.append(f"Row {row_num}: {error_msg}")
                
        connection.commit()
        
        return jsonify({
            "success_count": success_count,
            "failed_count": failed_count,
            "errors": errors[:10] # Limit errors returned to the UI array
        })
        
    except Exception as e:
        print(f"DEBUG [Bulk Upload]: {e}")
        return jsonify({"error": "Failed to parse file. Please ensure it is a valid CSV format."}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@admin_bp.route('/api/restaurants/template')
def download_restaurant_template():
    """Generates the required CSV template format on the fly."""
    if session.get('user_type') not in ['admin', 'helpdesk']:
        return jsonify({"error": "Unauthorized"}), 403
        
    output = io.StringIO()
    writer = csv.writer(output)
    
    # Write Headers (Includes Tax Rate now)
    writer.writerow(['RestaurantName', 'RestaurantCode', 'Address', 'City', 'State', 'Zip', 'TaxRate'])
    # Write Sample Row
    writer.writerow(['Times Square Flagship', 'NYC-001', '123 Broadway', 'New York', 'NY', '10036', '8.87'])
    
    return Response(
        output.getvalue(),
        mimetype="text/csv",
        headers={"Content-disposition": "attachment; filename=restaurant_import_template.csv"}
    )

    
# PHASE 2: USER PROVISIONING & TAGGING
# ==========================================
# SYSTEM USERS & ACCESS MANAGEMENT
# ==========================================

# ==========================================
# PHASE 2: SYSTEM USERS & ACCESS MANAGEMENT
# ==========================================

@admin_bp.route('/staff')
def manage_staff():
    """Loads the System Users Management Page"""
    connection = get_db_connection()
    users = []
    restaurants = []
    warehouses = [] # Added to fetch warehouses for the UI
    
    try:
        cursor = connection.cursor(dictionary=True)
        
        # 1. Fetch all system users and their mapped facilities
        cursor.callproc('GetSystemUsers')
        for res in cursor.stored_results():
            users = res.fetchall()
            
        # 2. Fetch restaurants to populate the modal's dropdown
        cursor.callproc('GetAdminRestaurants')
        for res in cursor.stored_results():
            restaurants = res.fetchall()
            
        # 3. Fetch warehouses to populate the Node picker
        cursor.callproc('GetAdminWarehouses')
        for res in cursor.stored_results():
            warehouses = res.fetchall()
            
    except Exception as e:
        print(f"DEBUG [Staff]: {e}")
        flash('Failed to load users.', 'error')
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

    return render_template('admin/users.html', users=users, restaurants=restaurants, warehouses=warehouses)


@admin_bp.route('/api/staff', methods=['POST', 'PUT'])
def api_save_staff():
    """Creates or Updates a System User & Tags to Location"""
    data = request.get_json()
    
    user_id = data.get('user_id')
    first_name = data.get('first_name')
    last_name = data.get('last_name', '')
    email = data.get('email')
    password = data.get('password')
    user_type = data.get('user_type')
    restaurant_id = data.get('restaurant_id')
    warehouse_id = data.get('warehouse_id') # Grab the warehouse ID from the frontend

    if not first_name or not email or not user_type:
        return jsonify({"error": "First Name, Email, and Access Role are required."}), 400

    if request.method == 'POST' and not password:
        return jsonify({'error': 'A password is required for new users.'}), 400

    # Ensure relationships are strictly enforced
    if user_type == 'restaurant' and not restaurant_id:
        return jsonify({"error": "You must select a Restaurant facility to tag this user to."}), 400
        
    if user_type in ['warehouse_manager', 'warehouse_worker'] and not warehouse_id:
        return jsonify({"error": "You must select a Network Node (Warehouse) to tag this staff member to."}), 400
        
    hashed_password = None
    if password:
        hashed_password = generate_password_hash(password)

    # Clean data before saving
    if user_type != 'restaurant':
        restaurant_id = None
    elif restaurant_id:
        restaurant_id = int(restaurant_id)

    # THE FIX: Allow BOTH warehouse roles to keep their warehouse_id
    if user_type not in ['warehouse_manager', 'warehouse_worker']:
        warehouse_id = None
    elif warehouse_id:
        warehouse_id = int(warehouse_id)

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        # THE FIX: Ensure exactly 8 parameters are passed to MySQL
        cursor.callproc('SaveSystemUser', [
            user_id, first_name, last_name, email, 
            hashed_password, user_type, restaurant_id, warehouse_id
        ])
        connection.commit()
        return jsonify({"success": True})
        
    except Exception as e:
        error_msg = str(e)
        if "Duplicate entry" in error_msg and "email" in error_msg.lower():
            error_msg = "An account with this email address already exists."
        return jsonify({"error": error_msg}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()