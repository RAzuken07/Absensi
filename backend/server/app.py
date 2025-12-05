from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from config import Config
from database.db import Database

# Import blueprints
from routes.auth_routes import auth_bp
from routes.admin_routes import admin_bp
from routes.dosen_routes import dosen_bp
from routes.face_routes import face_bp
from routes.absensi_routes import absensi_bp

def create_app():
    """Application factory"""
    app = Flask(__name__)
    
    # Load configuration
    app.config.from_object(Config)
    Config.init_app(app)
    
    # Initialize extensions
    CORS(app)
    jwt = JWTManager(app)
    
    # Initialize database
    try:
        Database.initialize()
    except Exception as e:
        print(f"Warning: Database initialization failed: {e}")
    
    # Register blueprints
    app.register_blueprint(auth_bp)
    app.register_blueprint(admin_bp)
    app.register_blueprint(dosen_bp)
    app.register_blueprint(face_bp)
    app.register_blueprint(absensi_bp)
    
    # Error handlers
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({'error': 'Endpoint not found'}), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        return jsonify({'error': 'Internal server error'}), 500
    
    @jwt.expired_token_loader
    def expired_token_callback(jwt_header, jwt_payload):
        return jsonify({'error': 'Token has expired'}), 401
    
    @jwt.invalid_token_loader
    def invalid_token_callback(error):
        return jsonify({'error': 'Invalid token'}), 401
    
    @jwt.unauthorized_loader
    def missing_token_callback(error):
        return jsonify({'error': 'Authorization token is missing'}), 401
    
    # Root endpoint
    @app.route('/')
    def index():
        return jsonify({
            'message': 'Attendance API Server',
            'version': '1.0.0',
            'status': 'running'
        }), 200
    
    # Health check
    @app.route('/health')
    def health():
        return jsonify({'status': 'healthy'}), 200
    
    return app

if __name__ == '__main__':
    app = create_app()
    print("\n" + "="*50)
    print("🚀 Attendance API Server Starting...")
    print("="*50)
    print(f"Server running on http://{Config.SERVER_HOST}:{Config.SERVER_PORT}")
    print("Press CTRL+C to stop\n")
    
    app.run(
        host=Config.SERVER_HOST,
        port=Config.SERVER_PORT,
        debug=Config.DEBUG
    )
