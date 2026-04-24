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
    Renders the checkout page. 
    Refactored to use Stored Procedures for B2B checks.
    """
    user_id = session.get('user_id')
    session_id = session.get('guest_id')
    store_id = session.get('store_id', 1)

    if not user_id and not session_id:
        return redirect(url_for('user.dashboard'))

    if not user_id:
        flash("Please log in to complete your purchase.", "info")
        session['next_url'] = url_for('orders.checkout')
        return redirect(url_for('auth.login'))

    connection = get_db_connection()
    cart_data = {'cart_items': [], 'subtotal': 0, 'tax': 0, 'total': 0}
    user_addresses = []
    user_phone = None 
    store_settings = None

    try:
        cursor = connection.cursor(dictionary=True)
        
        # 1. Fetch Store B2B Settings using SP
        cursor.callproc('GetStoreSettings', [store_id])
        for result in cursor.stored_results():
            rows = result.fetchall()
            if rows and not store_settings:
                store_settings = rows[0]

        # 2. Get Cart Details
        cursor.callproc('GetCartDetails', [user_id, session_id])
        for result in cursor.stored_results():
            rows = result.fetchall()
            if rows and not cart_data['cart_items']:
                cart_data['cart_items'] = rows
            
        if not cart_data['cart_items']:
            return redirect(url_for('cart.view_cart'))

        subtotal = sum(item['price'] * item['quantity'] for item in cart_data['cart_items'])
        tax = subtotal * Decimal('0.05')
        total = subtotal + tax
        cart_data.update({'subtotal': subtotal, 'tax': tax, 'total': total})
        
        # 3. B2B Validation Warnings
        if store_settings:
            min_val = store_settings.get('min_order_value') or Decimal('0.00')
            max_val = store_settings.get('max_order_value')
            
            if total < min_val:
                flash(f"Store Alert: Minimum order value is ${min_val}. Current: ${total}", "error")
            if max_val and total > max_val:
                flash(f"Store Alert: Maximum order value is ${max_val}.", "warning")
             
        # 4. Get User Details
        if user_id:
            cursor.callproc('GetUserAddresses', [user_id])
            for result in cursor.stored_results():
                rows = result.fetchall()
                if rows and not user_addresses:
                    user_addresses = rows
            
            cursor.callproc('GetUserPhone', [user_id])
            for result in cursor.stored_results():
                rows = result.fetchall()
                if rows and not user_phone:
                    if rows[0].get('phone'):
                        user_phone = rows[0]['phone']
                
    except Error as e:
        print(f"DEBUG - Checkout Page Error: {e}")
        return redirect(url_for('cart.view_cart'))
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()
            
    return render_template('order/checkout.html', cart=cart_data, addresses=user_addresses, user_phone=user_phone)

@orders_bp.route('/place_order', methods=['POST'])
def place_order():
    """
    API Endpoint to finalize the order.
    Refactored to use Stored Procedures for all updates.
    """
    data = request.get_json()
    user_id = session.get('user_id')
    session_id = session.get('guest_id')
    store_id = session.get('store_id', 1)
    
    if not user_id:
        return jsonify({"error": "User must be logged in to place an order."}), 401

    shipping_addr = data.get('shipping_address')
    billing_addr = data.get('billing_address')
    total_amount_float = data.get('total_amount')
    total_amount = Decimal(str(total_amount_float)) if total_amount_float else Decimal('0.00')
    
    guest_email = data.get('guest_email')
    guest_phone = data.get('guest_phone') 
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        
        # 1. Enforce B2B Limits (using SP)
        cursor.callproc('GetStoreSettings', [store_id])
        store_settings = None
        for result in cursor.stored_results():
            store_settings = result.fetchone()
        
        approval_threshold = None
        if store_settings:
            min_val = store_settings.get('min_order_value') or Decimal('0.00')
            max_val = store_settings.get('max_order_value')
            approval_threshold = store_settings.get('approval_threshold')
            
            if total_amount < min_val:
                 return jsonify({"error": f"Order value ${total_amount} is below the store minimum of ${min_val}."}), 400
            
            if max_val and total_amount > max_val:
                 return jsonify({"error": f"Order value exceeds the store maximum of ${max_val}."}), 400

        # 2. Create Order
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
            order_id = order_info['order_id']
            
            # 3. Check Approval Threshold (using SP)
            if store_settings and approval_threshold and total_amount > approval_threshold:
                cursor.callproc('SetOrderApprovalStatus', [order_id, 'pending_approval'])
                connection.commit()
                order_info['approval_required'] = True
            
            # 4. Update Contact Details (using SP)
            if guest_email:
                 cursor.callproc('SetOrderGuestEmail', [order_id, guest_email])
                 connection.commit()

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
    
    connection = get_db_connection()
    order = None
    items = []
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetOrderByNumber', [order_num])
        for result in cursor.stored_results():
            order = result.fetchone()
            
        if order:
            cursor.callproc('GetOrderItems', [order['order_id']])
            for result in cursor.stored_results():
                items = result.fetchall()
        else:
            flash("Order not found. Please check the tracking number.", "error")
    except Exception as e:
        print(f"Tracking Error: {e}")
        flash("An error occurred while tracking your order.", "error")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()
            
    return render_template('order/track.html', order=order, items=items)

# NEW: Real-Time Polling Endpoint for the Tracking Page
@orders_bp.route('/status/<order_number>', methods=['GET'])
def api_order_status(order_number):
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetOrderByNumber', [order_number])
        order = None
        for result in cursor.stored_results():
            order = result.fetchone()
        if order:
            return jsonify({"status": order['order_status']})
        return jsonify({"error": "Not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@orders_bp.route('/clone/<int:order_id>', methods=['POST'])
def clone_order(order_id):
    """Clones a previous order's items into the user's active cart."""
    user_id = session.get('user_id')
    guest_id = session.get('guest_id')
    
    if not user_id:
        return jsonify({"error": "You must be logged in to reorder."}), 401
        
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        # The SQL engine does 100% of the heavy lifting and stock checking
        cursor.callproc('CloneOrderToCart', [order_id, user_id, guest_id])
        connection.commit()
        return jsonify({"status": "success", "message": "Order successfully loaded into your cart!"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()




# --- B2B MANAGER APPROVAL ROUTES ---

@orders_bp.route('/approvals', methods=['GET'])
def approvals_dashboard():
    """Manager view to see pending orders for their assigned stores."""
    if not session.get('user_id') or not session.get('is_manager'):
        flash("Unauthorized access. Manager privileges required.", "error")
        return redirect(url_for('user.dashboard'))
        
    connection = get_db_connection()
    pending_orders = []
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetPendingApprovals', [session['user_id']])
        for result in cursor.stored_results():
            pending_orders = result.fetchall()
    except Error as e:
        print(f"Approval Dashboard Error: {e}")
    finally:
        if connection and connection.is_connected():
            connection.close()
            
    return render_template('order/approvals.html', orders=pending_orders)

@orders_bp.route('/approve/<int:order_id>', methods=['POST'])
def approve_order(order_id):
    """API to approve an order."""
    if not session.get('is_manager'):
        return jsonify({"error": "Unauthorized"}), 403
        
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('ApproveOrder', [order_id, session['user_id']])
        connection.commit()
        return jsonify({"message": "Order approved successfully"}), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

@orders_bp.route('/reject/<int:order_id>', methods=['POST'])
def reject_order(order_id):
    """API to reject an order (and restock inventory)."""
    if not session.get('is_manager'):
        return jsonify({"error": "Unauthorized"}), 403
        
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('RejectOrder', [order_id, session['user_id']])
        connection.commit()
        return jsonify({"message": "Order rejected and inventory restocked"}), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()