# File: __init__.py
# Location: /app/

import os
from flask import Flask, render_template, session, redirect, url_for
from dotenv import load_dotenv

# Relative imports are required inside a package
from .auth import auth
from .user import user_bp
from .cart import cart_bp
from .order import orders_bp
from .warehouse import warehouse_bp
from .admin import admin_bp # NEW: Import Admin Blueprint

load_dotenv()

def create_app():
    app = Flask(__name__)
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'default_secret')

    # Register Blueprints with URL prefixes
    app.register_blueprint(auth, url_prefix='/api/auth')
    app.register_blueprint(user_bp, url_prefix='/api/user')
    app.register_blueprint(cart_bp, url_prefix='/api/cart')
    app.register_blueprint(orders_bp, url_prefix='/api/orders')
    app.register_blueprint(warehouse_bp, url_prefix='/api/warehouse')
    app.register_blueprint(admin_bp, url_prefix='/admin') # NEW: Register Admin

    @app.route('/')
    def index():
        # SMART ROUTING: Helpdesk / Admin
        if session.get('user_id') and session.get('user_type') == 'helpdesk':
            return redirect(url_for('admin.dashboard'))
            
        # SMART ROUTING: Warehouse Staff
        if session.get('user_id') and session.get('user_type') in ['warehouse', 'warehouse_manager', 'warehouse_worker']:
            return redirect(url_for('warehouse.dashboard'))
            
        # Default fallback: Redirect guests and restaurant users to the shopping catalog
        return redirect(url_for('user.dashboard'))

    return app