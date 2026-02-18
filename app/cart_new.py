# File: cart.py
# Location: /app/

from flask import Blueprint, request, jsonify, session, render_template, redirect, url_for, flash
from mysql.connector import Error
from decimal import Decimal
import uuid

# Relative import
from .db import get_db_connection

cart_bp = Blueprint('cart', __name__)

def get_session_id():
    """Helper to get or create a guest session ID."""
    if 'guest_id' not in session:
        session['guest_id'] = str(uuid.uuid4())
    return session['guest_id']

@cart_bp.route('/', methods=['GET'])
def view_cart():
    user_id = session.get('user_id')
    guest_id = session.get('guest_id')

    # Default empty cart structure
    empty_cart = {'items': [], 'subtotal': 0, 'tax': 0, 'total': 0}

    # If no user and no guest session, return empty
    if not user_id and not guest_id:
        return render_template('cart/view.html', cart=empty_cart)

    connection = get_db_connection()
    cart_items = []
    
    try:
        cursor = connection.cursor(dictionary=True)
        # Use Stored Procedure to get items (including stock_quantity)
        cursor.callproc('GetCartDetails', [user_id, guest_id])
        for result in cursor.stored_results():
            cart_items = result.fetchall()
            
        if not cart_items:
             return render_template('cart/view.html', cart=empty_cart)

        # Calculate totals
        subtotal = sum(item['price'] * item['quantity'] for item in cart_items)
        tax = subtotal * Decimal('0.05')
        total = subtotal + tax
        
        # Package into 'cart' object for the template
        cart_data = {
            'items': cart_items,
            'subtotal': subtotal,
            'tax': tax,
            'total': total
        }
        
        return render_template('cart/view.html', cart=cart_data)
        
    except Error as e:
        print(f"Cart View Error: {e}")
        return render_template('cart/view.html', cart=empty_cart)
    finally:
        if connection and connection.is_connected():
            connection.close()

@cart_bp.route('/add', methods=['POST'])
def add_to_cart():
    data = request.get_json()
    product_id = data.get('product_id')
    quantity = data.get('quantity', 1)
    
    user_id = session.get('user_id')
    # Use existing guest_id or create one if user not logged in
    guest_id = session.get('guest_id')
    if not user_id and not guest_id:
        guest_id = get_session_id()

    if not product_id:
        return jsonify({"error": "Product ID required"}), 400

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        # Use Stored Procedure
        cursor.callproc('AddToCart', [user_id, guest_id, product_id, quantity])
        connection.commit()
        return jsonify({"message": "Item added to cart"}), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

@cart_bp.route('/update', methods=['POST'])
def update_quantity():
    data = request.get_json()
    cart_item_id = data.get('cart_item_id')
    new_quantity = data.get('quantity')
    
    user_id = session.get('user_id')
    guest_id = session.get('guest_id')

    if not cart_item_id or new_quantity is None:
        return jsonify({"error": "Missing data"}), 400

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        # Use Stored Procedure
        cursor.callproc('CartUpdateItem', [cart_item_id, new_quantity, user_id, guest_id])
        connection.commit()
        return jsonify({"message": "Cart updated"}), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

@cart_bp.route('/remove', methods=['POST'])
def remove_from_cart():
    data = request.get_json()
    cart_item_id = data.get('cart_item_id')
    
    user_id = session.get('user_id')
    guest_id = session.get('guest_id')

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        # Use Stored Procedure
        cursor.callproc('CartRemoveItem', [cart_item_id, user_id, guest_id])
        connection.commit()
        return jsonify({"message": "Item removed"}), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

@cart_bp.route('/set_quantity', methods=['POST'])
def set_product_quantity():
    """
    Sets the absolute quantity of a product or variant. 
    Used by Product Details and Category modals.
    """
    data = request.get_json()
    product_id = data.get('product_id')
    quantity = data.get('quantity')
    price = data.get('price') 
    variant_id = data.get('variant_id') 

    user_id = session.get('user_id')
    # Logic: If not logged in, ensure we have a guest_id
    guest_id = session.get('guest_id')
    if not user_id and not guest_id:
        guest_id = get_session_id()

    if product_id is None or quantity is None:
        return jsonify({"error": "Missing data"}), 400

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        # Use Stored Procedure
        cursor.callproc('SetCartQuantity', [user_id, guest_id, product_id, variant_id, quantity])
        connection.commit()
        return jsonify({"message": "Cart updated successfully"}), 200
    except Error as e:
        print(f"Set Quantity Error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

@cart_bp.route('/count', methods=['GET'])
def get_cart_count():
    user_id = session.get('user_id')
    guest_id = session.get('guest_id')
    
    if not user_id and not guest_id:
        return jsonify({"count": 0})

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        # Use Stored Procedure
        cursor.callproc('GetCartCount', [user_id, guest_id])
        count = 0
        for result in cursor.stored_results():
            row = result.fetchone()
            if row:
                count = row['total_items']
        return jsonify({"count": count})
    except Error as e:
        print(f"Cart Count Error: {e}")
        return jsonify({"count": 0})
    finally:
        if connection and connection.is_connected():
            connection.close()