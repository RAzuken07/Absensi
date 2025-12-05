import os
from datetime import timedelta

class Config:
    """Flask application configuration"""
    
    # Flask
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
    DEBUG = True
    
    # JWT Configuration
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or 'jwt-secret-key-change-in-production'
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=24)
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=30)
    
    # Database Configuration
    DB_HOST = os.environ.get('DB_HOST') or 'localhost'
    DB_USER = os.environ.get('DB_USER') or 'root'
    DB_PASSWORD = os.environ.get('DB_PASSWORD') or ''
    DB_NAME = os.environ.get('DB_NAME') or 'absensi'
    DB_PORT = int(os.environ.get('DB_PORT') or 3306)
    
    # Upload Configuration
    UPLOAD_FOLDER = 'uploads'
    FACE_FOLDER = os.path.join(UPLOAD_FOLDER, 'faces')
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB max file size
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
    
    # Face Recognition
    FACE_RECOGNITION_TOLERANCE = 0.6  # Lower is more strict
    
    # Geolocation
    CAMPUS_RADIUS_METERS = 50  # Default radius for attendance validation
    
    # Server
    SERVER_HOST = '0.0.0.0'
    SERVER_PORT = 5000
    
    @staticmethod
    def init_app(app):
        """Initialize application configuration"""
        # Create upload folders if they don't exist
        os.makedirs(Config.FACE_FOLDER, exist_ok=True)
