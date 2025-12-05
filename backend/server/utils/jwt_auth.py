from functools import wraps
from flask import jsonify
from flask_jwt_extended import verify_jwt_in_request, get_jwt_identity, get_jwt

def jwt_required_custom(fn):
    """Custom JWT required decorator"""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        verify_jwt_in_request()
        return fn(*args, **kwargs)
    return wrapper

def admin_required(fn):
    """Require admin role"""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        verify_jwt_in_request()
        claims = get_jwt()
        if claims.get('level') != 'admin':
            return jsonify({'error': 'Admin access required'}), 403
        return fn(*args, **kwargs)
    return wrapper

def dosen_required(fn):
    """Require dosen role"""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        verify_jwt_in_request()
        claims = get_jwt()
        if claims.get('level') not in ['admin', 'dosen']:
            return jsonify({'error': 'Dosen access required'}), 403
        return fn(*args, **kwargs)
    return wrapper

def mahasiswa_required(fn):
    """Require mahasiswa role"""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        verify_jwt_in_request()
        claims = get_jwt()
        if claims.get('level') not in ['admin', 'mahasiswa']:
            return jsonify({'error': 'Mahasiswa access required'}), 403
        return fn(*args, **kwargs)
    return wrapper

def get_current_user():
    """Get current user identity from JWT"""
    return get_jwt_identity()

def get_current_user_role():
    """Get current user role from JWT"""
    claims = get_jwt()
    return claims.get('level')

def get_current_user_data():
    """Get current user data from JWT"""
    return get_jwt()
