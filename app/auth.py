# File: auth.py
# Location: /app/

from flask import Blueprint, request, render_template, redirect, url_for, flash, session
from werkzeug.security import generate_password_hash, check_password_hash
from mysql.connector import Error

# Relative import for DB connection
from .db import get_db_connection

auth = Blueprint('auth', __name__)

@auth.route('/register', methods=['GET', 'POST'])
def register():
    # GET: Show the registration form
    if request.method == 'GET':
        return render_template('auth/register.html')

    # POST: Handle the form submission
    first_name = request.form.get('first_name')
    last_name = request.form.get('last_name')
    email = request.form.get('email')
    password = request.form.get('password')
    phone = request.form.get('phone')

    # Basic Validation
    if not all([first_name, email, password]):
        flash("First Name, Email, and Password are required.", "error")
        return render_template('auth/register.html')

    password_hash = generate_password_hash(password)
    connection = get_db_connection()
    
    try:
        cursor = connection.cursor(dictionary=True)
        
        # 1. Register the User
        cursor.callproc('RegisterUser', [first_name, last_name, email, password_hash, phone])
        connection.commit()
        
        # 2. AUTO-LOGIN: Fetch the new user immediately
        cursor.callproc('GetUserByEmail', [email])
        user = None
        for result in cursor.stored_results():
            user = result.fetchone()

        if user:
            # 3. Set Session (Log them in)
            session['user_id'] = user['user_id']
            session['first_name'] = user['first_name']
            session['email'] = user['email']
            
            # 4. CART PERSISTENCE: Merge Guest Cart Logic
            guest_session_id = session.get('guest_id')
            if guest_session_id:
                try:
                    # Move items from guest_id to user_id
                    cursor.callproc('MergeCarts', [guest_session_id, user['user_id']])
                    connection.commit()
                    
                    # Clear the guest ID as it's no longer needed
                    session.pop('guest_id', None)
                    print(f"DEBUG - Merged cart for guest {guest_session_id} to new user {user['user_id']}")
                except Error as e:
                    print(f"DEBUG - Cart Merge Error: {e}")
                    # We don't stop login if merge fails, but we log it

            flash(f"Registration successful! Welcome, {user['first_name']}.", "success")
            
            # Check for saved redirect URL (e.g., from checkout)
            next_url = session.pop('next_url', None)
            if next_url:
                return redirect(next_url)

            return redirect(url_for('user.dashboard'))
        
        # Fallback if user fetch fails (rare)
        flash("Registration successful! Please log in.", "success")
        return redirect(url_for('auth.login'))
        
    except Error as e:
        print(f"DEBUG - Registration Error: {e}")
        flash("Registration failed. Email might already be registered.", "error")
        return render_template('auth/register.html')
        
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@auth.route('/login', methods=['GET', 'POST'])
def login():
    # GET: Show the login form
    if request.method == 'GET':
        return render_template('auth/login.html')

    # POST: Handle the form submission
    email = request.form.get('email')
    password = request.form.get('password')

    if not email or not password:
        flash("Please enter both email and password.", "error")
        return render_template('auth/login.html')

    connection = get_db_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc('GetUserByEmail', [email])
        
        user = None
        for result in cursor.stored_results():
            user = result.fetchone()

        if user and check_password_hash(user['password_hash'], password):
            # Capture any existing anonymous session ID before logging in
            guest_session_id = session.get('guest_id')

            # Set Session
            # Set Multi-Tenant Session Variables
            session['user_id'] = user['user_id']
            session['first_name'] = user['first_name']
            session['last_name'] = user.get('last_name', '')
            session['email'] = user['email']
            session['is_manager'] = bool(user.get('is_manager'))
            session['user_type'] = user.get('user_type', 'restaurant')
            
            # Tag the user to their specific store/warehouse
            if user.get('assigned_store_id'):
                session['warehouse_id'] = user['assigned_store_id']
                session['warehouse_name'] = user['store_name']
            
            # --- CART PERSISTENCE LOGIC (Login) ---
            if guest_session_id:
                try:
                    cursor.callproc('MergeCarts', [guest_session_id, user['user_id']])
                    connection.commit()
                    session.pop('guest_id', None)
                    print(f"DEBUG - Merged cart for guest {guest_session_id} to user {user['user_id']}")
                except Exception as e:
                    print(f"DEBUG - Cart Merge Error: {e}")
            
            flash(f"Welcome back, {user['first_name']}!", "success")
            
            # Check for saved redirect URL (e.g., from checkout)
            next_url = session.pop('next_url', None)
            if next_url:
                return redirect(next_url)
                
            # NEW: Multi-Tenant Routing
            if session['user_type'] in ['warehouse', 'warehouse_manager', 'warehouse_worker']:
                return redirect(url_for('warehouse.dashboard'))
            elif session['user_type'] == 'restaurant':
                return redirect(url_for('user.dashboard'))
            elif session['user_type'] == 'helpdesk':
                return redirect(url_for('admin.dashboard'))
            else:
                return redirect(url_for('user.dashboard')) # Fallback
                
        else:
            flash("Invalid email or password.", "error")
            return render_template('auth/login.html')
            
    except Exception as e:
        print(f"DEBUG - Login Error: {e}")
        flash("An unexpected system error occurred. Please try again.", "error")
        return render_template('auth/login.html')
        
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

@auth.route('/logout')
def logout():
    session.clear()
    flash("You have been logged out.", "info")
    return redirect(url_for('auth.login'))