from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, create_refresh_token
from database.db import Database
from utils.password_hash import verify_password

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

@auth_bp.route('/login', methods=['POST'])
def login():
    """
    User login endpoint
    
    Request body:
    {
        "username": "string",
        "password": "string"
    }
    
    Returns:
        JWT access token and user info
    """
    try:
        data = request.get_json()
        
        if not data or 'username' not in data or 'password' not in data:
            return jsonify({'error': 'Username and password required'}), 400
        
        username = data['username']
        password = data['password']
        
        # Get user from database
        query = """
            SELECT u.*, 
                   CASE 
                       WHEN u.level = 'dosen' THEN d.nama
                       WHEN u.level = 'mahasiswa' THEN m.nama
                       ELSE u.nama
                   END as full_name
            FROM users u
            LEFT JOIN dosen d ON u.nip = d.nip
            LEFT JOIN mahasiswa m ON u.nim = m.nim
            WHERE u.username = %s
        """
        user = Database.execute_query(query, (username,), fetch_one=True)
        
        if not user:
            return jsonify({'error': 'Username atau password salah'}), 401
        
        # For development, support both plain text and hashed passwords
        password_valid = False
        if user['password'] == password:
            # Plain text password (for existing data)
            password_valid = True
        else:
            # Try bcrypt verification
            try:
                password_valid = verify_password(password, user['password'])
            except:
                password_valid = False
        
        if not password_valid:
            return jsonify({'error': 'Username atau password salah'}), 401
        
        # Create JWT token with user claims
        additional_claims = {
            'level': user['level'],
            'nim': user['nim'],
            'nip': user['nip'],
            'nama': user['full_name'] or user['nama']
        }
        
        access_token = create_access_token(
            identity=user['username'],
            additional_claims=additional_claims
        )
        refresh_token = create_refresh_token(identity=user['username'])
        
        # Remove password from response
        user_data = {
            'id_user': user['id_user'],
            'username': user['username'],
            'nama': user['full_name'] or user['nama'],
            'level': user['level'],
            'nim': user['nim'],
            'nip': user['nip']
        }
        
        return jsonify({
            'message': 'Login successful',
            'access_token': access_token,
            'refresh_token': refresh_token,
            'user': user_data
        }), 200
        
    except Exception as e:
        return jsonify({'error': f'Login failed: {str(e)}'}), 500

@auth_bp.route('/verify', methods=['GET'])
def verify_token():
    """Verify JWT token validity"""
    from utils.jwt_auth import jwt_required_custom, get_current_user_data
    
    @jwt_required_custom
    def _verify():
        user_data = get_current_user_data()
        return jsonify({
            'valid': True,
            'user': {
                'username': user_data.get('sub'),
                'level': user_data.get('level'),
                'nim': user_data.get('nim'),
                'nip': user_data.get('nip'),
                'nama': user_data.get('nama')
            }
        }), 200
    
    return _verify()

@auth_bp.route('/refresh', methods=['POST'])
def refresh():
    """Refresh access token"""
    from flask_jwt_extended import jwt_required, get_jwt_identity
    
    @jwt_required(refresh=True)
    def _refresh():
        identity = get_jwt_identity()
        access_token = create_access_token(identity=identity)
        return jsonify({'access_token': access_token}), 200
    
    return _refresh()
