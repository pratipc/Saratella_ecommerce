# File: user.py
# Location: /app/

from flask import Blueprint, request, jsonify, session, render_template, redirect, url_for, flash
from mysql.connector import Error
import json 
import uuid 
from .db import get_db_connection

user_bp = Blueprint('user', __name__)

def get_current_store_id():
    """Helper to get the current store context."""
    return session.get('store_id', 1)

# --- B2B STORE HIERARCHY API ---

@user_bp.route('/stores/hierarchy', methods=['GET'])
def get_store_hierarchy():
    """
    Returns the full hierarchy: Region -> Area -> Store
    Refactored to use Stored Procedure 'GetStoreHierarchy'.
    """
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        
        # CHANGED: Replaced inline SQL with SP call
        cursor.callproc('GetStoreHierarchy')
        
        rows = []
        for result in cursor.stored_results():
            rows = result.fetchall()
        
        # Transform flat rows into nested JSON structure
        hierarchy = {}
        for row in rows:
            r_id = row['region_id']
            if r_id not in hierarchy:
                hierarchy[r_id] = {
                    'id': r_id, 
                    'name': row['name'], 
                    'areas': {}
                }
            
            a_id = row['area_id']
            if a_id not in hierarchy[r_id]['areas']:
                hierarchy[r_id]['areas'][a_id] = {
                    'id': a_id,
                    'name': row['name'],
                    'stores': []
                }
                
            hierarchy[r_id]['areas'][a_id]['stores'].append({
                'id': row['store_id'],
                'name': row['name'],
                'code': row['store_code']
            })
            
        result = []
        for r in hierarchy.values():
            r['areas'] = list(r['areas'].values())
            result.append(r)
            
        return jsonify(result)
    except Error as e:
        print(f"Hierarchy Error: {e}")
        return jsonify({'error': str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/store/set', methods=['POST'])
def set_active_store():
    data = request.get_json()
    store_id = data.get('store_id')
    store_name = data.get('store_name')
    
    if not store_id:
        return jsonify({'error': 'Store ID required'}), 400
        
    session['store_id'] = store_id
    session['store_name'] = store_name
    
    # --- Bring in localized SKU Data for the selected store ---
    user_id = session.get('user_id')
    guest_id = session.get('guest_id')
    products = []
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        # Fetch SKUs visible ONLY to this newly selected store
        cursor.callproc('GetAllProducts', [user_id, guest_id, store_id])
        for result in cursor.stored_results():
            products = result.fetchall()
            
        return jsonify({
            'message': 'Store context updated', 
            'store_id': store_id,
            'products': products  # Sending SKU data directly in payload
        })
    except Error as e:
        print(f"Store Switch Error: {e}")
        return jsonify({'error': str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()


# --- MAIN SHOPPING ROUTES ---

@user_bp.route('/dashboard')
def dashboard():
    user_id = session.get('user_id')
    guest_id = session.get('guest_id')
    store_id = get_current_store_id()

    connection = get_db_connection()
    products = []
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetAllProducts', [user_id, guest_id, store_id])
        for result in cursor.stored_results():
            products = result.fetchall()
            
        return render_template('user/dashboard.html', user=session, products=products)
    except Error as e:
        print(f"DEBUG - Dashboard Error: {e}")
        return render_template('user/dashboard.html', user=session, products=[])
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/shop-by-category')
def shop_by_category():
    connection = get_db_connection()
    categories = []
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetAllCategories')
        for result in cursor.stored_results():
            categories = result.fetchall()
        return render_template('user/shop_by_category.html', categories=categories)
    except Error as e:
        return render_template('user/shop_by_category.html', categories=[])
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/search/config')
def search_config():
    connection = get_db_connection()
    data = {'categories': [], 'brands': []}
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetAllCategories')
        for result in cursor.stored_results():
            data['categories'] = result.fetchall()
        cursor.callproc('GetAllBrands')
        for result in cursor.stored_results():
            data['brands'] = result.fetchall()
        return jsonify(data)
    except Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/search')
def search_products():
    query = request.args.get('q', '')
    cat_id = request.args.get('category_id')
    brand_id = request.args.get('brand_id')
    min_price = request.args.get('min_price')
    max_price = request.args.get('max_price')
    
    # FIX: Get the active store_id from the session (default to 1 if not set)
    store_id = session.get('store_id', 1)
    
    cat_id = int(cat_id) if cat_id else None
    brand_id = int(brand_id) if brand_id else None
    min_price = float(min_price) if min_price else None
    max_price = float(max_price) if max_price else None
    
    connection = get_db_connection()
    results = []
    try:
        cursor = connection.cursor(dictionary=True)
        # FIX: Pass store_id as the 6th argument to match the Stored Procedure
        cursor.callproc('SearchProducts', [query, cat_id, brand_id, min_price, max_price, store_id])
        for res in cursor.stored_results():
            results = res.fetchall()
        return jsonify({'results': results})
    except Error as e:
        print(f"DEBUG [Search Error]: {e}")
        return jsonify({'error': str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close() # Good practice to explicitly close the cursor too
            connection.close()

@user_bp.route('/category/<int:category_id>')
def category_view(category_id):
    user_id = session.get('user_id')
    guest_id = session.get('guest_id')
    store_id = get_current_store_id()
    
    connection = get_db_connection()
    products = []
    category_name = "Category"
    
    try:
        cursor = connection.cursor(dictionary=True)
        
        cursor.callproc('GetCategoryName', [category_id])
        for result in cursor.stored_results():
            cat_row = result.fetchone()
            if cat_row:
                category_name = cat_row['name']

        cursor.callproc('GetProductsByCategory', [category_id, user_id, guest_id, store_id])
        for result in cursor.stored_results():
            products = result.fetchall()
            
        return render_template('user/category_products.html', products=products, category_name=category_name)
    except Error as e:
        return redirect(url_for('user.dashboard'))
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/product/<int:product_id>')
def product_detail(product_id):
    guest_id = session.get('guest_id')
    user_id = session.get('user_id')
    store_id = get_current_store_id()
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetProductDetails', [product_id, user_id, guest_id, store_id])
        product = None
        for result in cursor.stored_results():
            product = result.fetchone()
        
        if not product:
            flash("Product not found.", "error")
            return redirect(url_for('user.dashboard'))
            
        attributes = []
        variants_map = {}
        media_list = []

        if product.get('has_variants'):
            cursor.callproc('GetProductAttributes', [product_id])
            raw_attrs = []
            for result in cursor.stored_results():
                raw_attrs = result.fetchall()
            attr_dict = {}
            for row in raw_attrs:
                a_id = row['attribute_id']
                if a_id not in attr_dict:
                    attr_dict[a_id] = {'id': a_id, 'name': row['attribute_name'], 'options': []}
                attr_dict[a_id]['options'].append({
                    'id': row['value_id'],
                    'name': row['attribute_value'],
                    'color': row['color_code']
                })
            attributes = list(attr_dict.values())
            
            cursor.callproc('GetProductVariants', [product_id]) 
            for result in cursor.stored_results():
                for row in result.fetchall():
                    variants_map[row['combination_key']] = {
                        'id': row['variant_id'],
                        'price': float(row['price']),
                        'stock': int(row['stock_quantity']), 
                        'sku': row['sku'],
                        'image': row['image_url'],
                        'cart_quantity': 0 
                    }
            
            if user_id or guest_id:
                cursor.callproc('GetVariantCartQuantities', [product_id, user_id, guest_id])
                cart_rows = []
                for result in cursor.stored_results():
                    cart_rows = result.fetchall()
                
                for cart_item in cart_rows:
                    v_id = cart_item['variant_id']
                    qty = cart_item['quantity']
                    for key, val in variants_map.items():
                        if val['id'] == v_id:
                            variants_map[key]['cart_quantity'] = qty
                            break
        
        try:
            cursor.callproc('GetProductMedia', [product_id])
            for result in cursor.stored_results():
                media_list = result.fetchall()
        except Error:
            pass

        if not media_list and product.get('image_url'):
            media_list.append({
                'media_type': 'image',
                'media_url': product['image_url'],
                'media_id': 0
            })

        return render_template('user/product_detail.html', 
                             product=product, 
                             attributes=attributes, 
                             variants_map=json.dumps(variants_map),
                             media=media_list)

    except Error as e:
        return redirect(url_for('user.dashboard'))
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/product/<int:product_id>/variant-data')
def get_variant_data(product_id):
    user_id = session.get('user_id')
    guest_session_id = session.get('guest_id')
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetProductAttributes', [product_id])
        raw_attrs = []
        for result in cursor.stored_results():
            raw_attrs = result.fetchall()
        attr_dict = {}
        for row in raw_attrs:
            a_id = row['attribute_id']
            if a_id not in attr_dict:
                attr_dict[a_id] = {'id': a_id, 'name': row['attribute_name'], 'options': []}
            attr_dict[a_id]['options'].append({
                'id': row['value_id'],
                'name': row['attribute_value'],
                'color': row['color_code']
            })
        attributes = list(attr_dict.values())
        variants_map = {}
        cursor.callproc('GetProductVariants', [product_id])
        for result in cursor.stored_results():
            for row in result.fetchall():
                v_id = row['variant_id']
                variants_map[row['combination_key']] = {
                    'id': v_id,
                    'price': float(row['price']),
                    'stock': row['stock_quantity'],
                    'sku': row['sku'],
                    'image': row['image_url'],
                    'cart_quantity': 0 
                }
        if user_id or guest_session_id:
            cursor.callproc('GetVariantCartQuantities', [product_id, user_id, guest_session_id])
            cart_rows = []
            for result in cursor.stored_results():
                cart_rows = result.fetchall()
            for cart_item in cart_rows:
                v_id = cart_item['variant_id']
                qty = cart_item['quantity']
                for key, val in variants_map.items():
                    if val['id'] == v_id:
                        variants_map[key]['cart_quantity'] = qty
                        break
        return jsonify({'attributes': attributes, 'variants_map': variants_map})
    except Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/orders')
def my_orders():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
        
    user_id = session['user_id']
    orders = []
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetUserOrders', [user_id])
        for result in cursor.stored_results():
            orders = result.fetchall()
            
        return render_template('user/my_orders.html', orders=orders)
    except Error:
        return render_template('user/my_orders.html', orders=[])
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/profile')
def profile():
    user_id = session.get('user_id')
    if not user_id:
        return redirect(url_for('auth.login'))
        
    connection = get_db_connection()
    restaurant_tag = None
    
    try:
        cursor = connection.cursor(dictionary=True)
        
        # NEW: Fetch the tagged restaurant for this user
        cursor.callproc('GetUserRestaurantTag', [user_id])
        for res in cursor.stored_results():
            row = res.fetchone()
            if row:
                restaurant_tag = row
                
        # ... (keep any other existing database calls you have here for addresses/orders) ...
                
    except Error as e:
        print(f"DEBUG [Profile Error]: {e}")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()
            
    # NEW: Ensure you pass restaurant_tag=restaurant_tag to the template!
    return render_template('user/profile.html', restaurant_tag=restaurant_tag)

@user_bp.route('/profile/edit', methods=['GET', 'POST'])
def edit_profile():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))

    user_id = session['user_id']
    if request.method == 'GET':
        connection = get_db_connection()
        user_data = {}
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.callproc('GetUserProfile', [user_id])
            for result in cursor.stored_results():
                user_data = result.fetchone()
        finally:
            if connection and connection.is_connected():
                connection.close()
        
        if not user_data:
            return redirect(url_for('user.profile'))
            
        return render_template('user/edit_profile.html', user=user_data)

    first_name = request.form.get('first_name')
    last_name = request.form.get('last_name')
    phone = request.form.get('phone')
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('UpdateUserProfile', [user_id, first_name, last_name, phone])
        connection.commit()
        session['first_name'] = first_name
        flash("Profile updated successfully.", "success")
        return redirect(url_for('user.profile'))
    except Error:
        flash("Failed to update profile.", "error")
        return redirect(url_for('user.edit_profile'))
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/addresses')
def get_addresses():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
        
    connection = get_db_connection()
    active_addresses = []
    inactive_addresses = []
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetUserAddresses', [session['user_id']])
        for result in cursor.stored_results():
            all_addresses = result.fetchall()
            for addr in all_addresses:
                addr_type = addr.get('address_type') or ''
                if addr_type.lower() == 'inactive':
                    inactive_addresses.append(addr)
                else:
                    active_addresses.append(addr)
    finally:
        if connection and connection.is_connected():
            connection.close()
            
    return render_template('user/addresses.html', active_addresses=active_addresses, inactive_addresses=inactive_addresses)

@user_bp.route('/address/add', methods=['POST'])
def add_address():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
    
    user_id = session['user_id']
    data = request.form
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('AddUserAddress', [
            user_id,
            data.get('address_type'),
            data.get('address_line1'),
            data.get('address_line2'),
            data.get('city'),
            data.get('state'),
            data.get('postal_code'),
            data.get('country')
        ])
        connection.commit()
        flash("Address added successfully.", "success")
    except Error:
        flash("Failed to add address.", "error")
    finally:
        if connection and connection.is_connected():
            connection.close()
            
    return redirect(url_for('user.get_addresses'))

@user_bp.route('/address/edit', methods=['POST'])
def edit_address():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
    user_id = session['user_id']
    data = request.form
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('UpdateAddress', [
            data.get('address_id'), 
            user_id, 
            data.get('address_type'), 
            data.get('address_line1'), 
            data.get('address_line2'), 
            data.get('city'), 
            data.get('state'), 
            data.get('postal_code'), 
            data.get('country')
        ])
        connection.commit()
        flash("Address updated successfully.", "success")
    except Error:
        flash("Failed to update address.", "error")
    finally:
        if connection and connection.is_connected():
            connection.close()
    return redirect(url_for('user.get_addresses'))

@user_bp.route('/address/delete', methods=['POST'])
def delete_address():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
        
    address_id = request.form.get('address_id')
    user_id = session['user_id']
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('SoftDeleteAddress', [address_id, user_id])
        connection.commit()
        flash("Address marked as inactive.", "info")
    except Error:
        flash("Failed to delete address.", "error")
    finally:
        if connection and connection.is_connected():
            connection.close()
            
    return redirect(url_for('user.get_addresses'))

@user_bp.route('/product/notify', methods=['POST'])
def notify_stock():
    data = request.get_json()
    email = data.get('email')
    product_id = data.get('product_id')
    variant_id = data.get('variant_id') 

    if not email or not product_id:
        return jsonify({"error": "Email and Product ID required"}), 400

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('SubscribeToStock', [email, product_id, variant_id])
        connection.commit()
        return jsonify({"message": "Subscribed successfully"}), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

# Notice we removed the /api at the front of this route!
@user_bp.route('/product/<int:product_id>/grouped-data', methods=['GET'])
def get_grouped_data(product_id):
    """Fetches all child products belonging to a Grouped/Bundle product"""
    connection = get_db_connection()
    children = []
    
    # Get the store_id from the user's session (or default to 1 if guest)
    store_id = session.get('assigned_store_id', 1) 
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetGroupedProductChildren', [product_id, store_id])
        for result in cursor.stored_results():
            children = result.fetchall()
            
        return jsonify({"success": True, "children": children})
    except Exception as e:
        print(f"DEBUG [Grouped Products]: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()