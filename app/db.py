import os
import mysql.connector
from mysql.connector import Error

def get_db_connection():
    """Establishes a connection to the MySQL database using env vars."""
    try:
        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            user=os.getenv('DB_USER', 'root'),
            password=os.getenv('DB_PASSWORD', ''),
            database=os.getenv('DB_NAME', 'ecommerce_db')
        )
        return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None