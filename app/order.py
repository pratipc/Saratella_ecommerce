# File: order.py
# Location: /app/

from flask import Blueprint, request, jsonify, render_template, session, redirect, url_for, flash, json
from mysql.connector import Error
from decimal import Decimal

# Relative import
from .db import get_db_connection

orders_bp = Blueprint('orders', __name__)

@orders_bp.route('/checkout', methods=['GET'])
def checkout():
    """
    Renders the checkout page. 
    Refactored to be Global Storefront agnostic (removed store_id).
    """
    user_id = session.get('user_id')
    session_id = session.get('guest_id')

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
    tax_rate_display = 0.00 # NEW: Initialize tax display variable

    try:
        cursor = connection.cursor(dictionary=True)
        
        # 1. Get Cart Details (store_id parameter removed)
        cursor.callproc('GetCartDetails', [user_id, session_id])
        for result in cursor.stored_results():
            rows = result.fetchall()
            if rows and not cart_data['cart_items']:
                cart_data['cart_items'] = rows
            
        if not cart_data['cart_items']:
            return redirect(url_for('cart.view_cart'))

        # NEW: Fetch dynamic tax rate based on user's restaurant mapping
        tax_multiplier = Decimal('0.00')
        if user_id:
            cursor.callproc('GetUserTaxRate', [user_id])
            for result in cursor.stored_results():
                tax_row = result.fetchone()
                if tax_row and tax_row['tax_rate'] is not None:
                    tax_rate_display = float(tax_row['tax_rate'])
                    tax_multiplier = Decimal(str(tax_row['tax_rate'])) / Decimal('100')

        # Calculate totals securely using Decimal
        if cart_data['cart_items']:
            subtotal = sum(Decimal(str(item['price'])) * item['quantity'] for item in cart_data['cart_items'])
            tax = subtotal * tax_multiplier
            total = subtotal + tax
            cart_data.update({'subtotal': subtotal, 'tax': tax, 'total': total})
             
        # 2. Get User Details
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
            
    # NEW: Pass tax_rate_display to the frontend template
    return render_template('order/checkout.html', cart=cart_data, addresses=user_addresses, user_phone=user_phone, tax_rate_display=tax_rate_display)


@orders_bp.route('/place', methods=['POST'])
def place_order():
    data = request.get_json()
    user_id = session.get('user_id')
    session_id = session.get('guest_id')

    # Fetch variables exactly as passed from checkout.html
    shipping_addr = data.get('shipping_address')
    billing_addr = data.get('billing_address')
    total_amount = data.get('total_amount')

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        
        # 2. Create Order using your existing proven procedure
        cursor.callproc('CreateOrderFromCart', [
            user_id, 
            session_id, 
            shipping_addr, 
            billing_addr, 
            total_amount
        ])
        
        order_res = None
        for result in cursor.stored_results():
            order_res = result.fetchone()
            
        connection.commit()
        
        if order_res:
            return jsonify({"success": True, "order": order_res})
        else:
            return jsonify({"error": "Order could not be placed"}), 400
            
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            connection.close()

# =========================================================================
# EXISTING ROUTES (Restored original POST structure)
# =========================================================================

@orders_bp.route('/confirmation/<order_number>')
def confirmation(order_number):
    user_id = session.get('user_id')
    connection = get_db_connection()
    tax_rate_display = 0.00
    
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
            
        # NEW: Fetch dynamic tax rate based on user's restaurant mapping
        if user_id:
            cursor.callproc('GetUserTaxRate', [user_id])
            for result in cursor.stored_results():
                tax_row = result.fetchone()
                if tax_row and tax_row['tax_rate'] is not None:
                    tax_rate_display = float(tax_row['tax_rate'])
        
        return render_template('order/confirmation.html', order=order, items=items, tax_rate_display=tax_rate_display)
        
    except Error as e:
        print(f"Confirmation Error: {e}")
        return redirect(url_for('user.dashboard'))
    finally:
        if connection and connection.is_connected():
            cursor.close()
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
            # FIX: Call the upgraded, unified GetOrderItems procedure
            cursor.callproc('GetOrderItems', [order['order_id']])
            for result in cursor.stored_results():
                raw_items = result.fetchall()
                
                # Parse the JSON allocations so Jinja can loop through them in HTML
                for item in raw_items:
                    if item.get('allocations_json'):
                        try:
                            item['allocations'] = json.loads(item['allocations_json'])
                        except:
                            item['allocations'] = []
                    else:
                        item['allocations'] = []
                
                items = raw_items
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

# =========================================================================
# LIVE TRACKING POLLING API (NEW)
# =========================================================================
@orders_bp.route('/api/orders/status/<order_number>', methods=['GET'])
def api_track_order_status(order_number):
    """Endpoint for Alpine.js live polling to animate the tracking progress bar."""
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetOrderByNumber', [order_number])
        
        order = None
        for result in cursor.stored_results():
            order = result.fetchone()
            
        if order:
            return jsonify({"status": order['order_status']})
        else:
            return jsonify({"error": "Order not found"}), 404
    except Exception as e:
        print(f"DEBUG [Live Polling]: {e}")
        return jsonify({"error": str(e)}), 500
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