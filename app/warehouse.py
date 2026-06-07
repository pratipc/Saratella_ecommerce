import json
from flask import Blueprint, render_template, session, redirect, url_for, flash, jsonify, request
from .db import get_db_connection
from werkzeug.security import generate_password_hash

warehouse_bp = Blueprint('warehouse', __name__, url_prefix='/warehouse')

@warehouse_bp.before_request
def require_warehouse_login():
    if not session.get('user_id'):
        return redirect(url_for('auth.login'))
    if session.get('user_type') not in ['warehouse', 'warehouse_manager', 'warehouse_worker']:
        flash('Unauthorized. Warehouse access only.', 'error')
        return redirect(url_for('user.dashboard'))

# ==========================================
# SHARED DASHBOARD VIEW (SMART ROUTED)
# ==========================================
@warehouse_bp.route('/dashboard')
def dashboard():
    user_type = session.get('user_type')
    user_id = session.get('user_id')
    
    kpis = {"new_orders": 0, "action_needed": 0, "shipped_today": 0, "low_stock_alerts": 0}
    queue = []
    backorders = []

    if user_id:
        connection = get_db_connection()
        try:
            cursor = connection.cursor(dictionary=True)
            
            # SMART ROUTING: Fetch the right data using mapping table inside DB
            if user_type == 'warehouse_worker':
                cursor.callproc('GetWorkerDashboardStats', [user_id])
            else:
                cursor.callproc('GetWarehouseDashboardStats', [user_id])
            
            results = list(cursor.stored_results())
            if len(results) > 0:
                fetched_kpis = results[0].fetchone()
                if fetched_kpis: kpis = fetched_kpis
            
            if len(results) > 1:
                queue = results[1].fetchall()
            
            for order in queue:
                if order.get('created_at'):
                    order['formatted_date'] = order['created_at'].strftime("%b %d, %Y")
                    order['formatted_time'] = order['created_at'].strftime("%I:%M %p")
                    
            cursor.close()
            
            # Fetch Backorders ONLY for Managers
            if user_type == 'warehouse_manager':
                cursor = connection.cursor(dictionary=True)
                cursor.callproc('GetPendingBackorders', [user_id])
                for result in cursor.stored_results():
                    backorders = result.fetchall()

        except Exception as e:
            print(f"DEBUG [Warehouse Dashboard] - ERROR: {e}")
        finally:
            if connection and connection.is_connected():
                cursor.close()
                connection.close()

    return render_template('warehouse/dashboard.html', kpis=kpis, queue=queue, backorders=backorders)

# ==========================================
# MANAGER ONLY VIEWS
# ==========================================
@warehouse_bp.route('/queue')
def fulfillment_queue():
    if session.get('user_type') != 'warehouse_manager':
        flash('Access Denied. Managers only.', 'error')
        return redirect(url_for('warehouse.dashboard'))
    
    user_id = session.get('user_id')
    pending_queue = []
    active_queue = []
    staff = []

    if user_id:
        connection = get_db_connection()
        try:
            cursor = connection.cursor(dictionary=True)
            
            # Fetch the highly optimized queues via user mapping
            cursor.callproc('GetWarehouseDashboardStats', [user_id])
            results = list(cursor.stored_results())
            
            if len(results) > 1:
                pending_queue = results[1].fetchall()
            if len(results) > 2:
                active_queue = results[2].fetchall()
                
            # Helper to format dates
            def format_dates(q):
                for order in q:
                    if order.get('created_at'):
                        order['formatted_date'] = order['created_at'].strftime("%b %d, %Y")
                        order['formatted_time'] = order['created_at'].strftime("%I:%M %p")
            
            format_dates(pending_queue)
            format_dates(active_queue)
            
            # Fetch the staff list to populate the dropdowns
            cursor.nextset()
            cursor.callproc('GetWarehouseWorkers', [user_id])
            for result in cursor.stored_results():
                staff = result.fetchall()

        except Exception as e:
            print(f"DEBUG [Fulfillment Queue] - ERROR: {e}")
        finally:
            if connection and connection.is_connected():
                cursor.close()
                connection.close()

    return render_template('warehouse/manager_queue.html', 
                           pending_queue=pending_queue, 
                           active_queue=active_queue,
                           staff=staff)

@warehouse_bp.route('/api/orders/bulk-release', methods=['POST'])
def api_bulk_release_orders():
    if session.get('user_type') != 'warehouse_manager':
        return jsonify({"error": "Unauthorized"}), 403
        
    manager_id = session.get('user_id')
    data = request.get_json()
    order_ids = data.get('order_ids', [])
    
    if not order_ids:
        return jsonify({"error": "No orders selected."}), 400

    order_ids_json = json.dumps(order_ids)

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('BulkReleaseOrders', [manager_id, order_ids_json])
        connection.commit()
        return jsonify({"success": True})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@warehouse_bp.route('/api/order/<int:order_id>/assign', methods=['POST'])
def assign_worker(order_id):
    if session.get('user_type') != 'warehouse_manager':
        return jsonify({"error": "Unauthorized"}), 403
        
    manager_id = session.get('user_id') 
    data = request.get_json()
    worker_id = data.get('worker_id')
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('AssignWarehouseWorker', [order_id, worker_id, manager_id])
        connection.commit()
        return jsonify({"success": True})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@warehouse_bp.route('/staff')
def manage_staff():
    if session.get('user_type') != 'warehouse_manager':
        flash('Access Denied. Managers only.', 'error')
        return redirect(url_for('warehouse.dashboard'))
    return render_template('warehouse/manage_staff.html')

# ==========================================
# WORKER ONLY VIEWS
# ==========================================
@warehouse_bp.route('/pick-and-pack')
def pick_and_pack():
    if session.get('user_type') != 'warehouse_worker':
        flash('Access Denied. Workers only.', 'error')
        return redirect(url_for('warehouse.dashboard'))
        
    worker_id = session.get('user_id')
    tasks = []

    if worker_id:
        connection = get_db_connection()
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.callproc('GetWorkerTasks', [worker_id])
            
            results = list(cursor.stored_results())
            if len(results) > 0:
                tasks = results[0].fetchall()
            
            for task in tasks:
                if task.get('created_at'):
                    task['formatted_date'] = task['created_at'].strftime("%b %d, %Y")
                    task['formatted_time'] = task['created_at'].strftime("%I:%M %p")
        except Exception as e:
            print(f"DEBUG [Worker Tasks] - ERROR: {e}")
        finally:
            if connection and connection.is_connected():
                cursor.close()
                connection.close()

    return render_template('warehouse/worker_pick.html', tasks=tasks)

@warehouse_bp.route('/api/order/<int:order_id>/claim', methods=['POST'])
def claim_task(order_id):
    if session.get('user_type') != 'warehouse_worker':
        return jsonify({"error": "Unauthorized"}), 403

    worker_id = session.get('user_id')

    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('AssignWarehouseWorker', [order_id, worker_id, worker_id])
        connection.commit()
        return jsonify({"success": True})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

# NEW: Worker History Route
@warehouse_bp.route('/history')
def worker_history():
    if session.get('user_type') != 'warehouse_worker':
        flash('Access Denied. Workers only.', 'error')
        return redirect(url_for('warehouse.dashboard'))
        
    worker_id = session.get('user_id')
    tasks = []

    if worker_id:
        connection = get_db_connection()
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.callproc('GetWorkerCompletedTasks', [worker_id])
            
            results = list(cursor.stored_results())
            if len(results) > 0:
                tasks = results[0].fetchall()
            
            for task in tasks:
                if task.get('completed_at'):
                    task['formatted_date'] = task['completed_at'].strftime("%b %d, %Y")
                    task['formatted_time'] = task['completed_at'].strftime("%I:%M %p")
        except Exception as e:
            print(f"DEBUG [Worker History] - ERROR: {e}")
        finally:
            if connection and connection.is_connected():
                cursor.close()
                connection.close()

    return render_template('warehouse/worker_history.html', tasks=tasks)

# ==========================================
# THIN APIs (Heavy Lifting done in MySQL)
# ==========================================

@warehouse_bp.route('/api/staff', methods=['GET'])
def api_get_staff():
    if session.get('user_type') != 'warehouse_manager':
        return jsonify({"error": "Unauthorized"}), 403
        
    manager_id = session.get('user_id')
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetWarehouseWorkers', [manager_id])
        
        staff = []
        for result in cursor.stored_results():
            staff = result.fetchall()
            
        return jsonify({"staff": staff})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@warehouse_bp.route('/api/staff', methods=['POST'])
def api_add_staff():
    if session.get('user_type') != 'warehouse_manager':
        return jsonify({"error": "Unauthorized"}), 403
        
    manager_id = session.get('user_id')
    data = request.get_json()
    
    first_name = data.get('first_name')
    email = data.get('email')
    password = data.get('password')
    
    if not first_name or not email or not password:
        return jsonify({"error": "First name, email, and password are required."}), 400
        
    hashed_pw = generate_password_hash(password)
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('AddWarehouseWorker', [
            manager_id, 
            first_name, 
            data.get('last_name', ''), 
            email, 
            data.get('phone', ''), 
            hashed_pw
        ])
        connection.commit()
        return jsonify({"success": True})
    except Exception as e:
        error_msg = str(e).split(':')[-1].strip() if ':' in str(e) else str(e)
        return jsonify({"error": error_msg}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@warehouse_bp.route('/api/staff/<int:worker_id>', methods=['PUT'])
def api_update_staff(worker_id):
    if session.get('user_type') != 'warehouse_manager':
        return jsonify({"error": "Unauthorized"}), 403
        
    manager_id = session.get('user_id')
    data = request.get_json()
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('UpdateWarehouseWorker', [
            worker_id,
            manager_id,
            data.get('first_name'),
            data.get('last_name', ''),
            data.get('phone', '')
        ])
        connection.commit()
        return jsonify({"success": True})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@warehouse_bp.route('/api/staff/<int:worker_id>/status', methods=['POST'])
def api_toggle_staff_status(worker_id):
    if session.get('user_type') != 'warehouse_manager':
        return jsonify({"error": "Unauthorized"}), 403
        
    manager_id = session.get('user_id')
    data = request.get_json()
    is_active = 1 if data.get('is_active') else 0
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('ToggleWorkerStatus', [worker_id, manager_id, is_active])
        connection.commit()
        return jsonify({"success": True})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

# ==========================================
# SHARED APIs
# ==========================================

@warehouse_bp.route('/api/dashboard-stats', methods=['GET'])
def get_dashboard_stats():
    user_type = session.get('user_type')
    user_id = session.get('user_id')
    
    if not user_id:
        return jsonify({"error": "No user session found."}), 400

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        
        # SMART ROUTING: DB verifies the user_store_mapping
        if user_type == 'warehouse_worker':
            cursor.callproc('GetWorkerDashboardStats', [user_id])
        else:
            cursor.callproc('GetWarehouseDashboardStats', [user_id])
        
        results = list(cursor.stored_results())
        kpis = results[0].fetchone() if len(results) > 0 else {}
        queue = results[1].fetchall() if len(results) > 1 else []
        
        for order in queue:
            if order.get('created_at'):
                order['formatted_date'] = order['created_at'].strftime("%b %d, %Y")
                order['formatted_time'] = order['created_at'].strftime("%I:%M %p")
                
        backorders = []
        if user_type == 'warehouse_manager':
            cursor.close()
            cursor = connection.cursor(dictionary=True)
            cursor.callproc('GetPendingBackorders', [user_id])
            for result in cursor.stored_results():
                backorders = result.fetchall()
                
        return jsonify({"kpis": kpis, "queue": queue, "backorders": backorders})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@warehouse_bp.route('/api/order/<int:order_id>', methods=['GET'])
def get_order_details(order_id):
    user_id = session.get('user_id')
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetWarehouseOrderDetails', [order_id, user_id])
        
        results = list(cursor.stored_results())
        order_header = None
        order_items = []
        
        if len(results) > 0:
            order_header = results[0].fetchone()
        if len(results) > 1:
            order_items = results[1].fetchall()
        
        if not order_header:
            return jsonify({"error": f"Order {order_id} not found or you don't have access."}), 404
            
        return jsonify({"order": order_header, "items": order_items})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@warehouse_bp.route('/api/order/<int:order_id>/status', methods=['POST'])
def update_order_status(order_id):
    worker_id = session.get('user_id') 
    data = request.get_json(silent=True) or {}
    
    new_status = data.get('status')
    picked_items = data.get('picked_items', []) 
    
    if new_status not in ['processing', 'shipped', 'partially_shipped', 'cancelled']:
        return jsonify({"error": "Invalid status update."}), 400
        
    # Safely dump JSON, or pass None if perfectly empty
    items_json_str = json.dumps(picked_items) if picked_items is not None else '[]'
        
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('ProcessOrderFulfillment', [order_id, new_status, items_json_str, worker_id])
        connection.commit()
        return jsonify({"success": True, "message": f"Order marked as {new_status}!"})
    except Exception as e:
        print(f"DEBUG [Fulfillment API]: Error - {str(e)}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

# ==========================================
# EXCEPTIONS API (MANAGER ONLY)
# ==========================================
@warehouse_bp.route('/exceptions')
def exceptions_queue():
    if session.get('user_type') != 'warehouse_manager':
        flash('Access Denied. Managers only.', 'error')
        return redirect(url_for('warehouse.dashboard'))
    return render_template('warehouse/exceptions.html')

@warehouse_bp.route('/api/exceptions', methods=['GET'])
def api_get_exceptions():
    if session.get('user_type') != 'warehouse_manager':
        return jsonify({"error": "Unauthorized"}), 403
        
    manager_id = session.get('user_id')
    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetWarehouseExceptions', [manager_id])
        
        exceptions = []
        for result in cursor.stored_results():
            exceptions = result.fetchall()
            
        for exc in exceptions:
            if exc.get('created_at'):
                exc['formatted_date'] = exc['created_at'].strftime("%b %d, %Y - %I:%M %p")
                
        return jsonify({"exceptions": exceptions})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@warehouse_bp.route('/api/exceptions/<int:exception_id>/resolve', methods=['POST'])
def api_resolve_exception(exception_id):
    if session.get('user_type') != 'warehouse_manager':
        return jsonify({"error": "Unauthorized"}), 403
        
    manager_id = session.get('user_id')
    data = request.get_json()
    
    raw_manager_count = data.get('manager_count')
    manager_count = int(raw_manager_count) if raw_manager_count not in [None, ''] else 0
    
    raw_expected_qty = data.get('expected_qty')
    expected_qty = int(raw_expected_qty) if raw_expected_qty not in [None, ''] else 0

    reason_code = data.get('reason_code', 'Unknown')
    order_action = data.get('order_action', 'cancel')
    notes = data.get('notes', '')
    
    inventory_action = 'Found Item' if manager_count >= expected_qty else 'Shrinkage Accepted'
    
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('ResolveWarehouseException', [
            exception_id, 
            manager_id, 
            inventory_action,
            manager_count,
            reason_code,
            order_action,
            notes
        ])
        connection.commit()
        return jsonify({"success": True})
    except Exception as e:
        print(f"DEBUG [Resolve Exception]: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()


@warehouse_bp.route('/api/exceptions/history', methods=['GET'])
def api_get_exceptions_history():
    if session.get('user_type') != 'warehouse_manager':
        flash('Access Denied. Managers only.', 'error')
        return redirect(url_for('warehouse.dashboard'))
        
    manager_id = session.get('user_id')
    connection = get_db_connection()
    exceptions = []
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetResolvedWarehouseExceptions', [manager_id])
        
        for result in cursor.stored_results():
            exceptions = result.fetchall()
            
        for exc in exceptions:
            if exc.get('updated_at'):
                exc['formatted_date'] = exc['updated_at'].strftime("%b %d, %Y - %I:%M %p")
                
    except Exception as e:
        print(f"DEBUG [Audit History]: {e}")
        flash('Failed to load audit history.', 'error')
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()
            
    return render_template('warehouse/exceptions_history.html', exceptions=exceptions)

# ==========================================
# BACKORDERS API
# ==========================================
@warehouse_bp.route('/backorders')
def backorders_queue():
    if session.get('user_type') != 'warehouse_manager':
        flash('Access Denied. Managers only.', 'error')
        return redirect(url_for('warehouse.dashboard'))
        
    manager_id = session.get('user_id')
    connection = get_db_connection()
    backorders = []
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetPendingBackorders', [manager_id])
        for result in cursor.stored_results():
            backorders = result.fetchall()
            
        for b in backorders:
            if b.get('created_at'):
                b['formatted_date'] = b['created_at'].strftime("%b %d, %Y")
    except Exception as e:
        print(f"DEBUG [Backorders]: {e}")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()
            
    return render_template('warehouse/backorders.html', backorders=backorders)

@warehouse_bp.route('/api/backorders/<int:backorder_id>/release', methods=['POST'])
def release_backorder(backorder_id):
    if session.get('user_type') != 'warehouse_manager':
        return jsonify({"error": "Unauthorized"}), 403
        
    manager_id = session.get('user_id')
    connection = get_db_connection()
    try:
        cursor = connection.cursor()
        cursor.callproc('ReleaseBackorderToFloor', [backorder_id, manager_id])
        connection.commit()
        return jsonify({"success": True})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()