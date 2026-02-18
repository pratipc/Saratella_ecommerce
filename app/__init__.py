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

load_dotenv()

def create_app():
    app = Flask(__name__)
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'default_secret')

    # Register Blueprints with URL prefixes
    app.register_blueprint(auth, url_prefix='/api/auth')
    app.register_blueprint(user_bp, url_prefix='/api/user')
    app.register_blueprint(cart_bp, url_prefix='/api/cart')
    app.register_blueprint(orders_bp, url_prefix='/api/orders')

    @app.route('/')
    def index():
        # Redirect EVERYONE to the product dashboard
        # The dashboard now handles guests gracefully
        return redirect(url_for('user.dashboard'))

    return app