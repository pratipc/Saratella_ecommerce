# File: user.py
# Location: /app/

from flask import Blueprint, request, jsonify, session, render_template, redirect, url_for, flash
from mysql.connector import Error
import json 
import uuid 
from .db import get_db_connection

user_bp = Blueprint('user', __name__)

# ==========================================
# STOREFRONT PAGES & DASHBOARD
# ==========================================

@user_bp.route('/')
@user_bp.route('/dashboard')
def dashboard():
    user_id = session.get('user_id')
    guest_id = session.get('guest_id')

    connection = get_db_connection()
    products = []
    
    try:
        cursor = connection.cursor(dictionary=True)
        # CHANGED: store_id parameter removed
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

@user_bp.route('/category/<int:category_id>')
def category_products(category_id):
    user_id = session.get('user_id')
    guest_id = session.get('guest_id')
    connection = get_db_connection()
    products = []
    category_name = "Category"
    try:
        cursor = connection.cursor(dictionary=True)
        
        # Replaced inline query with stored procedure
        cursor.callproc('GetCategoryName', [category_id])
        for result in cursor.stored_results():
            cat = result.fetchone()
            if cat and 'name' in cat:
                category_name = cat['name']
                
        # Replaced inline query with stored procedure (store_id removed)
        cursor.callproc('GetProductsByCategory', [category_id, user_id, guest_id])
        for result in cursor.stored_results():
            products = result.fetchall()
        
        return render_template('user/category_products.html', user=session, products=products, category_name=category_name)
    except Error as e:
        print(f"DEBUG - Category Products Error: {e}")
        return render_template('user/category_products.html', user=session, products=[], category_name="Error")
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/product/<int:product_id>')
def product_detail(product_id):
    guest_id = session.get('guest_id')
    user_id = session.get('user_id')
    #store_id = get_current_store_id()
    
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

# ==========================================
# SEARCH APIS
# ==========================================

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

@user_bp.route('/api/search', methods=['GET'])
def search():
    query = request.args.get('q', '')
    cat_id = request.args.get('category_id') or None
    brand_id = request.args.get('brand_id') or None
    min_price = request.args.get('min_price') or None
    max_price = request.args.get('max_price') or None

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        # CHANGED: store_id parameter removed
        cursor.callproc('SearchProducts', [query, cat_id, brand_id, min_price, max_price])
        results = []
        for res in cursor.stored_results():
            results = res.fetchall()
        return jsonify({'results': results})
    except Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

# ==========================================
# GROUPED PRODUCT API
# ==========================================

@user_bp.route('/product/<int:product_id>/grouped-data', methods=['GET'])
def get_grouped_data(product_id):
    """Fetches all child products belonging to a Grouped/Bundle product"""
    connection = get_db_connection()
    children = []
    
    try:
        cursor = connection.cursor(dictionary=True)
        # CHANGED: store_id parameter removed
        cursor.callproc('GetGroupedProductChildren', [product_id])
        for result in cursor.stored_results():
            children = result.fetchall()
            
        return jsonify({"success": True, "children": children})
    except Exception as e:
        print(f"DEBUG [Grouped Products API]: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

# ==========================================
# USER PROFILE & ORDERS
# ==========================================

@user_bp.route('/profile')
def profile():
    user_id = session.get('user_id')
    if not user_id:
        return redirect(url_for('auth.login'))
        
    connection = get_db_connection()
    restaurant_tag = None
    
    try:
        cursor = connection.cursor(dictionary=True)
        
        cursor.callproc('GetUserRestaurantTag', [user_id])
        for res in cursor.stored_results():
            row = res.fetchone()
            if row:
                restaurant_tag = row
                
    except Error as e:
        print(f"DEBUG [Profile Error]: {e}")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()
            
    return render_template('user/profile.html', restaurant_tag=restaurant_tag)

@user_bp.route('/my-orders')
def my_orders():
    user_id = session.get('user_id')
    if not user_id:
        return redirect(url_for('auth.login'))
        
    connection = get_db_connection()
    orders = []
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetUserOrders', [user_id])
        for result in cursor.stored_results():
            orders = result.fetchall()
            
        for order in orders:
            if order.get('created_at'):
                order['formatted_date'] = order['created_at'].strftime("%B %d, %Y")
                
    except Error as e:
        print(f"DEBUG - My Orders Error: {e}")
    finally:
        if connection and connection.is_connected():
            connection.close()
            
    return render_template('user/my_orders.html', user=session, orders=orders)

@user_bp.route('/api/addresses', methods=['GET', 'POST', 'PUT', 'DELETE'])
def addresses_api():
    """Combined API for fetching, creating, updating, and deleting addresses"""
    user_id = session.get('user_id')
    if not user_id:
        return jsonify({"error": "Unauthorized"}), 401

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)

        if request.method == 'GET':
            cursor.callproc('GetUserAddresses', [user_id])
            addrs = []
            for result in cursor.stored_results():
                addrs = result.fetchall()
            return jsonify({"addresses": addrs})

        elif request.method == 'POST':
            data = request.get_json()
            cursor.callproc('AddUserAddress', [
                user_id, data.get('address_type', 'shipping'), data.get('address_line1'),
                data.get('address_line2', ''), data.get('city'), data.get('state', ''),
                data.get('postal_code'), data.get('country', 'USA'), data.get('is_default', 0)
            ])
            connection.commit()
            return jsonify({"success": True})

        elif request.method == 'PUT':
            data = request.get_json()
            address_id = data.get('address_id')
            if not address_id:
                return jsonify({"error": "address_id required"}), 400
                
            cursor.callproc('UpdateUserAddress', [
                address_id, user_id, data.get('address_type', 'shipping'), data.get('address_line1'),
                data.get('address_line2', ''), data.get('city'), data.get('state', ''),
                data.get('postal_code'), data.get('country', 'USA'), data.get('is_default', 0)
            ])
            connection.commit()
            return jsonify({"success": True})

        elif request.method == 'DELETE':
            data = request.get_json()
            address_id = data.get('address_id')
            if not address_id:
                return jsonify({"error": "address_id required"}), 400
                
            cursor.callproc('DeleteUserAddress', [address_id, user_id])
            connection.commit()
            return jsonify({"success": True})

    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

@user_bp.route('/addresses')
def get_addresses():
    if not session.get('user_id'):
        return redirect(url_for('auth.login'))
    return render_template('user/addresses.html', user=session)

@user_bp.route('/edit-profile')
def edit_profile():
    if not session.get('user_id'):
        return redirect(url_for('auth.login'))
    return render_template('user/edit_profile.html', user=session)

# ==========================================
# NOTIFICATIONS (Back in Stock)
# ==========================================

@user_bp.route('/api/subscribe', methods=['POST'])
def subscribe_stock():
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