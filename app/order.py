# File: order.py
# Location: /app/

from flask import Blueprint, request, jsonify, render_template, session, redirect, url_for, flash
from mysql.connector import Error
from decimal import Decimal

# Relative import
from .db import get_db_connection

orders_bp = Blueprint('orders', __name__)

@orders_bp.route('/checkout', methods=['GET'])
def checkout():
    """
    Renders the checkout page (GET request).
    """
    user_id = session.get('user_id')
    session_id = session.get('guest_id')

    # If no items in cart (neither user nor guest session), redirect to dashboard
    if not user_id and not session_id:
        return redirect(url_for('user.dashboard'))

    # CHECK: If User is NOT logged in (Guest), redirect to Login first
    if not user_id:
        flash("Please log in to complete your purchase.", "info")
        # Store the intended destination so auth.py can redirect back
        session['next_url'] = url_for('orders.checkout')
        return redirect(url_for('auth.login'))

    connection = get_db_connection()
    # FIX: Renamed 'items' to 'cart_items' to avoid Jinja2 collision with dict.items()
    cart_data = {'cart_items': [], 'subtotal': 0, 'tax': 0, 'total': 0}
    user_addresses = []
    user_phone = None 

    try:
        cursor = connection.cursor(dictionary=True)
        
        # 1. Get Cart Details for Summary
        cursor.callproc('GetCartDetails', [user_id, session_id])
        for result in cursor.stored_results():
            # FIX: Assign to 'cart_items'
            cart_data['cart_items'] = result.fetchall()
            
        if not cart_data['cart_items']:
            return redirect(url_for('cart.view_cart'))

        # Calculate totals
        subtotal = sum(item['price'] * item['quantity'] for item in cart_data['cart_items'])
        tax = subtotal * Decimal('0.05')
        total = subtotal + tax
        cart_data.update({'subtotal': subtotal, 'tax': tax, 'total': total})
             
        # 2. Get User Details (Addresses & Phone)
        if user_id:
            # Fetch Saved Addresses
            cursor.callproc('GetUserAddresses', [user_id])
            for result in cursor.stored_results():
                user_addresses = result.fetchall()
            
            # Fetch User's Phone Number
            cursor.callproc('GetUserPhone', [user_id])
            for result in cursor.stored_results():
                user_row = result.fetchone()
                if user_row and user_row.get('phone'):
                    user_phone = user_row['phone']
                
    except Error as e:
        print(f"DEBUG - Checkout Page Error: {e}")
        return redirect(url_for('cart.view_cart'))
    finally:
         if connection and connection.is_connected():
            connection.close()
            
    return render_template('order/checkout.html', cart=cart_data, addresses=user_addresses, user_phone=user_phone)

@orders_bp.route('/place_order', methods=['POST'])
def place_order():
    """
    API Endpoint to finalize the order (POST request).
    """
    data = request.get_json()
    user_id = session.get('user_id')
    session_id = session.get('guest_id')
    
    # Validation: Ensure user is logged in
    if not user_id:
        return jsonify({"error": "User must be logged in to place an order."}), 401

    shipping_addr = data.get('shipping_address')
    billing_addr = data.get('billing_address')
    total_amount = data.get('total_amount')
    guest_email = data.get('guest_email')
    guest_phone = data.get('guest_phone') 
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        
        # 1. Create Order (SP)
        cursor.callproc('CreateOrderFromCart', [
            user_id, 
            session_id, 
            shipping_addr, 
            billing_addr, 
            total_amount
        ])
        connection.commit()
        
        order_info = None
        for result in cursor.stored_results():
            order_info = result.fetchone()

        if order_info:
            # 2. Update Guest Email/Phone if provided
            if guest_email or guest_phone:
                try:
                    cursor.callproc('UpdateOrderContactDetails', [
                        order_info['order_id'], 
                        guest_email,
                        guest_phone
                    ])
                    connection.commit()
                except Error:
                    pass 

            if session_id:
                session.pop('guest_id', None)
                
            return jsonify({"message": "Order placed successfully", "order": order_info}), 201
        else:
             return jsonify({"error": "Failed to create order record"}), 500

    except Error as e:
        print(f"DEBUG - Place Order Error: {e}")
        error_msg = str(e)
        if "out of stock" in error_msg.lower() or "45000" in error_msg:
            return jsonify({"error": "One or more items in your cart are out of stock. Please update your cart."}), 400
        return jsonify({"error": error_msg}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

# ... (Confirmation and Track routes remain unchanged) ...
@orders_bp.route('/confirmation/<order_number>')
def confirmation(order_number):
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetOrderByNumber', [order_number])
        order = None
        for result in cursor.stored_results():
            order = result.fetchone()
        
        if not order:
            flash("Order not found.", "error")
            return redirect(url_for('user.dashboard'))
            
        cursor.callproc('GetOrderItems', [order['order_id']])
        items = []
        for result in cursor.stored_results():
            items = result.fetchall()
        
        return render_template('order/confirmation.html', order=order, items=items)
        
    except Error as e:
        print(f"Confirmation Error: {e}")
        return redirect(url_for('user.dashboard'))
    finally:
        if connection and connection.is_connected():
            connection.close()

@orders_bp.route('/track', methods=['GET', 'POST'])
def track_order():
    if request.method == 'GET':
        return render_template('order/track.html')
    order_num = request.form.get('order_number')
    email = request.form.get('email')
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('TrackOrder', [order_num, email])
        order = None
        for result in cursor.stored_results():
            order = result.fetchone()
        if order:
            return redirect(url_for('orders.confirmation', order_number=order['order_number']))
        else:
            flash("Order not found or email does not match.", "error")
            return render_template('order/track.html')
    except Error as e:
        print(f"Tracking Error: {e}")
        flash("System error. Please try again.", "error")
        return render_template('order/track.html')
    finally:
        if connection and connection.is_connected():
            connection.close()