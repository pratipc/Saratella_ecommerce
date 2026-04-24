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

def get_current_store_id():
    """Helper to get store context (Defaults to 1)"""
    return session.get('store_id', 1)

# --- DASHBOARD "SMART" UPDATE ROUTE ---
@cart_bp.route('/set_quantity', methods=['POST'])
def set_product_quantity():
    """
    Sets the absolute quantity of a product or variant. 
    """
    data = request.get_json()
    product_id = data.get('product_id')
    quantity = data.get('quantity')
    price = data.get('price')
    variant_id = data.get('variant_id') 

    user_id = session.get('user_id')
    store_id = get_current_store_id()
    session_id = None
    if not user_id:
        session_id = get_session_id()

    if product_id is None or quantity is None:
        return jsonify({"error": "Missing data"}), 400

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        
        # Call stored procedure with store_id
        cursor.callproc('CartSetProductQuantity', [
            user_id, 
            session_id, 
            product_id, 
            quantity, 
            price,
            variant_id,
            store_id # Pass store context for inventory check
        ])
        connection.commit()
        
        # Recalculate total items for badge
        cursor.callproc('GetCartCount', [user_id, session_id, store_id])
        count = 0
        for result in cursor.stored_results():
            row = result.fetchone()
            if row:
                count = row[0]
                
        return jsonify({"message": "Cart updated", "total_items": count}), 200

    except Error as e:
        error_message = str(e)
        if "45000" in error_message:
            parts = error_message.split(':')
            clean_msg = parts[-1].strip() if len(parts) > 1 else "Insufficient stock available."
            return jsonify({"error": clean_msg}), 400
            
        print(f"Cart Error: {e}")
        return jsonify({"error": "System error updating cart"}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

@cart_bp.route('/', methods=['GET'])
def view_cart():
    user_id = session.get('user_id')
    session_id = session.get('guest_id')
    store_id = get_current_store_id()

    connection = get_db_connection()
    cart_items = []
    subtotal = 0
    tax = 0
    total = 0

    try:
        cursor = connection.cursor(dictionary=True)
        # GetCartDetails filters by user/session, store_id context is implied by what was added
        cursor.callproc('GetCartDetails', [user_id, session_id])
        
        for result in cursor.stored_results():
            cart_items = result.fetchall()
            
        # Calculate totals in Python
        subtotal = sum(item['price'] * item['quantity'] for item in cart_items)
        tax = subtotal * Decimal('0.05')
        total = subtotal + tax

    except Error as e:
        print(f"Error fetching cart: {e}")
    finally:
        if connection and connection.is_connected():
            connection.close()

    return render_template('cart/view.html', cart_items=cart_items, subtotal=subtotal, tax=tax, total=total)

@cart_bp.route('/count', methods=['GET'])
def get_cart_count():
    user_id = session.get('user_id')
    session_id = session.get('guest_id')
    store_id = get_current_store_id()
    
    connection = get_db_connection()
    count = 0
    try:
        cursor = connection.cursor()
        # Updated to accept store_id
        cursor.callproc('GetCartCount', [user_id, session_id, store_id])
        for result in cursor.stored_results():
            row = result.fetchone()
            if row:
                count = row[0]
    except Error:
        pass
    finally:
        if connection and connection.is_connected():
            connection.close()
            
    return jsonify({"count": count})

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
        cursor = connection.cursor(dictionary=True)
        
        # We rely on DB Stored Proc to check inventory/locking.
        cursor.callproc('CartUpdateItem', [cart_item_id, new_quantity, user_id, guest_id])
        connection.commit()
        return jsonify({"message": "Cart updated"}), 200
        
    except Error as e:
        error_message = str(e)
        if "45000" in error_message:
            parts = error_message.split(':')
            clean_msg = parts[-1].strip() if len(parts) > 1 else "High demand! Stock held by other users."
            return jsonify({"error": clean_msg}), 400
            
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

@cart_bp.route('/remove', methods=['POST'])
def remove_from_cart():
    data = request.get_json()
    cart_item_id = data.get('cart_item_id')
    user_id = session.get('user_id')
    session_id = session.get('guest_id')

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('CartRemoveItem', [cart_item_id, user_id, session_id])
        connection.commit()
        return jsonify({"message": "Item removed"}), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()