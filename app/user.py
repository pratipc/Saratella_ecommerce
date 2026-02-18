# File: user.py
# Location: /app/

from flask import Blueprint, request, jsonify, session, render_template, redirect, url_for, flash
from mysql.connector import Error
import json 
import uuid 
from .db import get_db_connection

user_bp = Blueprint('user', __name__)

# --- MAIN SHOPPING ROUTES ---

@user_bp.route('/dashboard')
def dashboard():
    user_id = session.get('user_id')
    guest_id = session.get('guest_id')

    connection = get_db_connection()
    products = []
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetAllProducts', [user_id, guest_id])
        for result in cursor.stored_results():
            products = result.fetchall()
            
        return render_template('user/dashboard.html', user=session, products=products)
    except Error as e:
        print(f"DEBUG - Dashboard Error: {e}")
        return render_template('user/dashboard.html', user=session, products=[])
    finally:
        if connection and connection.is_connected():
            connection.close()

# --- NEW ROUTE: Shop by Category ---
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
        print(f"Error fetching categories: {e}")
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
    cat_id = int(cat_id) if cat_id else None
    brand_id = int(brand_id) if brand_id else None
    min_price = float(min_price) if min_price else None
    max_price = float(max_price) if max_price else None
    connection = get_db_connection()
    results = []
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('SearchProducts', [query, cat_id, brand_id, min_price, max_price])
        for res in cursor.stored_results():
            results = res.fetchall()
        return jsonify({'results': results})
    except Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/category/<int:category_id>')
def category_view(category_id):
    user_id = session.get('user_id')
    guest_id = session.get('guest_id')
    connection = get_db_connection()
    products = []
    category_name = "Category"
    
    try:
        cursor = connection.cursor(dictionary=True)
        
        # REPLACED: Inline query with Stored Procedure call
        cursor.callproc('GetCategoryName', [category_id])
        for result in cursor.stored_results():
            cat_row = result.fetchone()
            if cat_row:
                category_name = cat_row['name']

        # Products fetch with user context (Preserving your working logic)
        cursor.callproc('GetProductsByCategory', [category_id, user_id, guest_id])
        for result in cursor.stored_results():
            products = result.fetchall()
            
        return render_template('user/category_products.html', products=products, category_name=category_name)
    except Error as e:
        print(f"Category Error: {e}")
        return redirect(url_for('user.dashboard'))
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/product/<int:product_id>')
def product_detail(product_id):
    guest_id = session.get('guest_id')
    user_id = session.get('user_id')
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetProductDetails', [product_id, user_id, guest_id])
        product = None
        for result in cursor.stored_results():
            product = result.fetchone()
        if not product:
            flash("Product not found.", "error")
            return redirect(url_for('user.dashboard'))
            
        attributes = []
        variants_map = {}
        
        # New: Media List Container
        media_list = []

        if product.get('has_variants'):
            # 1. Fetch Attributes
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
            
            # 2. Fetch Variants and Initialize Map
            cursor.callproc('GetProductVariants', [product_id])
            for result in cursor.stored_results():
                for row in result.fetchall():
                    variants_map[row['combination_key']] = {
                        'id': row['variant_id'],
                        'price': float(row['price']),
                        'stock': row['stock_quantity'],
                        'sku': row['sku'],
                        'image': row['image_url'],
                        'cart_quantity': 0 
                    }
            
            # 3. Populate Cart Quantities
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
        
        # 4. FETCH PRODUCT MEDIA (New Logic)
        try:
            cursor.callproc('GetProductMedia', [product_id])
            for result in cursor.stored_results():
                media_list = result.fetchall()
        except Error as err:
            print(f"Media fetch error (non-critical): {err}")

        # Fallback if no media in DB: Use main product image
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
                             media=media_list) # Pass media to template

    except Error as e:
        print(f"DEBUG - Product Detail Error: {e}")
        return redirect(url_for('user.dashboard'))
    finally:
        if connection and connection.is_connected():
            connection.close()


# --- MISSING API: Product Variants (Fixes 404 Error) ---
# ... (Keep existing routes: get_variant_data, product_detail, search, etc.) ...
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
# --- ORDER HISTORY ---

@user_bp.route('/orders')
def my_orders():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
        
    user_id = session['user_id']
    orders = []
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        # Use Stored Procedure for orders
        cursor.callproc('GetUserOrders', [user_id])
        for result in cursor.stored_results():
            orders = result.fetchall()
            
        return render_template('user/my_orders.html', orders=orders)
    except Error as e:
        print(f"Error fetching orders: {e}")
        return render_template('user/my_orders.html', orders=[])
    finally:
        if connection and connection.is_connected():
            connection.close()

# --- PROFILE & ADDRESSES ---

@user_bp.route('/profile')
def profile():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
        
    connection = get_db_connection()
    user_data = None
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetUserProfile', [session['user_id']])
        for result in cursor.stored_results():
            user_data = result.fetchone()
            
    except Error as e:
        print(f"Profile Error: {e}")
        
    finally:
        if connection and connection.is_connected():
            connection.close()
            
    if not user_data:
        flash("Could not load profile details.", "error")
        # Redirect to dashboard or logout if critical data missing
        return redirect(url_for('user.dashboard'))
            
    return render_template('user/profile.html', user=user_data)

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

    # POST logic
    first_name = request.form.get('first_name')
    last_name = request.form.get('last_name')
    phone = request.form.get('phone')
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('UpdateUserProfile', [user_id, first_name, last_name, phone])
        connection.commit()
        
        # Update session
        session['first_name'] = first_name
        flash("Profile updated successfully.", "success")
        return redirect(url_for('user.profile'))
    except Error as e:
        print(f"Update Profile Error: {e}")
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
            
            # Split into Active and Inactive based on address_type
            for addr in all_addresses:
                # FIX: Handle potential None value for address_type
                # Ensure we have a string before calling .lower()
                addr_type = addr.get('address_type') or ''
                
                if addr_type.lower() == 'inactive':
                    inactive_addresses.append(addr)
                else:
                    active_addresses.append(addr)
                    
    except Error as e:
        print(f"Address Error: {e}")
    finally:
        if connection and connection.is_connected():
            connection.close()
            
    return render_template('user/addresses.html', 
                         active_addresses=active_addresses, 
                         inactive_addresses=inactive_addresses)

@user_bp.route('/address/add', methods=['POST'])
def add_address():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
    
    user_id = session['user_id']
    data = request.form
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        # Use Stored Procedure
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
    except Error as e:
        print(f"Add Address Error: {e}")
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
        # Use Stored Procedure
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
    except Error as e:
        print(f"Edit Address Error: {e}")
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
        
        # SOFT DELETE: Update address_type to 'inactive' using SP
        cursor.callproc('SoftDeleteAddress', [address_id, user_id])
        connection.commit()
        
        flash("Address marked as inactive.", "info")
    except Error as e:
        print(f"Delete Address Error: {e}")
        flash("Failed to delete address.", "error")
    finally:
        if connection and connection.is_connected():
            connection.close()
            
    return redirect(url_for('user.get_addresses'))

# --- NOTIFICATIONS ---

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
        # Use Stored Procedure
        cursor.callproc('SubscribeToStock', [email, product_id, variant_id])
        connection.commit()
        return jsonify({"message": "Subscribed successfully"}), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()