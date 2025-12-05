import mysql.connector
from mysql.connector import pooling
from config import Config

class Database:
    """Database connection manager with connection pooling"""
    
    _connection_pool = None
    
    @classmethod
    def initialize(cls):
        """Initialize the connection pool"""
        try:
            cls._connection_pool = pooling.MySQLConnectionPool(
                pool_name="absensi_pool",
                pool_size=5,
                host=Config.DB_HOST,
                port=Config.DB_PORT,
                user=Config.DB_USER,
                password=Config.DB_PASSWORD,
                database=Config.DB_NAME
            )
            print("✓ Database connection pool initialized successfully")
        except mysql.connector.Error as err:
            print(f"✗ Error initializing database pool: {err}")
            raise
    
    @classmethod
    def get_connection(cls):
        """Get a connection from the pool"""
        if cls._connection_pool is None:
            cls.initialize()
        return cls._connection_pool.get_connection()
    
    @classmethod
    def execute_query(cls, query, params=None, fetch_one=False, fetch_all=False, commit=False):
        """
        Execute a database query
        
        Args:
            query: SQL query string
            params: Query parameters (tuple or dict)
            fetch_one: Return single row
            fetch_all: Return all rows
            commit: Commit the transaction
            
        Returns:
            Query result or None
        """
        connection = None
        cursor = None
        try:
            connection = cls.get_connection()
            cursor = connection.cursor(dictionary=True)
            
            cursor.execute(query, params or ())
            
            if commit:
                connection.commit()
                return cursor.lastrowid
            
            if fetch_one:
                return cursor.fetchone()
            
            if fetch_all:
                return cursor.fetchall()
            
            return None
            
        except mysql.connector.Error as err:
            if connection:
                connection.rollback()
            print(f"Database error: {err}")
            raise
        finally:
            if cursor:
                cursor.close()
            if connection:
                connection.close()
    
    @classmethod
    def execute_many(cls, query, params_list):
        """Execute multiple queries with different parameters"""
        connection = None
        cursor = None
        try:
            connection = cls.get_connection()
            cursor = connection.cursor()
            
            cursor.executemany(query, params_list)
            connection.commit()
            
            return cursor.rowcount
            
        except mysql.connector.Error as err:
            if connection:
                connection.rollback()
            print(f"Database error: {err}")
            raise
        finally:
            if cursor:
                cursor.close()
            if connection:
                connection.close()
