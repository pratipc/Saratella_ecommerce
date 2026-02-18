# File: user.py
# Location: /app/

from flask import Blueprint, request, jsonify, session, render_template, redirect, url_for, flash
from mysql.connector import Error
import json 
import uuid 
from .db import get_db_connection

user_bp = Blueprint('user', __name__)

@user_bp.route('/dashboard')
def dashboard():
    user_id = session.get('user_id')
    guest_id = session.get('guest_id')

    connection = get_db_connection()
    products = []
    # Removed categories fetch from dashboard as it is moved
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetAllProducts', [user_id, guest_id])
        for result in cursor.stored_results():
            products = result.fetchall()
            
        # No longer passing categories to dashboard
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
                        'stock': row['stock_quantity'],
                        'sku': row['sku'],
                        'image': row['image_url']
                    }
        return render_template('user/product_detail.html', product=product, attributes=attributes, variants_map=json.dumps(variants_map))
    except Error as e:
        print(f"DEBUG - Product Detail Error: {e}")
        return redirect(url_for('user.dashboard'))
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
        cursor.execute("SELECT name FROM categories WHERE category_id = %s", (category_id,))
        cat_row = cursor.fetchone()
        if cat_row:
            category_name = cat_row['name']
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

@user_bp.route('/profile')
def profile():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT user_id, first_name, last_name, email, phone FROM users WHERE user_id = %s", (session['user_id'],))
        user = cursor.fetchone()
        return render_template('user/profile.html', user=user)
    except Error:
        return redirect(url_for('user.dashboard'))
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/profile/edit', methods=['GET', 'POST'])
def edit_profile():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        if request.method == 'GET':
            cursor.execute("SELECT first_name, last_name, email, phone FROM users WHERE user_id = %s", (session['user_id'],))
            user = cursor.fetchone()
            return render_template('user/edit_profile.html', user=user)
        elif request.method == 'POST':
            first_name = request.form.get('first_name')
            last_name = request.form.get('last_name')
            phone = request.form.get('phone')
            cursor.callproc('UpdateUserProfile', [session['user_id'], first_name, last_name, phone])
            connection.commit()
            return redirect(url_for('user.profile'))
    except Error:
        return redirect(url_for('user.profile'))
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/my-orders')
def my_orders():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
    connection = get_db_connection()
    orders = []
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetUserOrders', [session['user_id']])
        for result in cursor.stored_results():
            orders = result.fetchall()
        return render_template('user/my_orders.html', orders=orders)
    except Error:
        return render_template('user/my_orders.html', orders=[])
    finally:
        if connection and connection.is_connected():
            connection.close()

# --- ADDED: My Downloads Route ---
@user_bp.route('/my-downloads')
def my_downloads():
    if 'user_id' not in session:
        flash("Please login to access your library.", "info")
        return redirect(url_for('auth.login'))
    
    connection = get_db_connection()
    downloads = []
    try:
        cursor = connection.cursor(dictionary=True)
        # Note: Ensure GetUserDownloads stored procedure exists
        cursor.callproc('GetUserDownloads', [session['user_id']])
        for result in cursor.stored_results():
            downloads = result.fetchall()
        return render_template('user/my_downloads.html', downloads=downloads)
    except Error as e:
        print(f"Error fetching downloads: {e}")
        return render_template('user/my_downloads.html', downloads=[])
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/addresses', methods=['GET'])
def get_addresses():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
    user_id = session['user_id']
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetUserAddresses', [user_id])
        addresses = []
        for result in cursor.stored_results():
            addresses = result.fetchall()
        return render_template('user/addresses.html', addresses=addresses)
    except Error:
        return redirect(url_for('user.dashboard'))
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/address/add', methods=['POST'])
def add_address():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
    user_id = session['user_id']
    data = request.form
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('AddAddress', [user_id, data.get('address_type'), data.get('address_line1'), data.get('address_line2'), data.get('city'), data.get('state'), data.get('postal_code'), data.get('country')])
        connection.commit()
    except Error:
        pass
    finally:
        if connection and connection.is_connected():
            connection.close()
    return redirect(url_for('user.get_addresses'))

@user_bp.route('/address/delete/<int:address_id>', methods=['POST'])
def delete_address(address_id):
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('DeleteAddress', [address_id, session['user_id']])
        connection.commit()
    except Error:
        pass
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
        cursor.callproc('UpdateAddress', [data.get('address_id'), user_id, data.get('address_type'), data.get('address_line1'), data.get('address_line2'), data.get('city'), data.get('state'), data.get('postal_code'), data.get('country')])
        connection.commit()
    except Error:
        pass
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
        return jsonify({"message": "You will be notified when stock is available."}), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()