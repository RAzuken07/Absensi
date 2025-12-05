from flask import Blueprint, request, jsonify
from services.face_service import FaceService
from utils.jwt_auth import jwt_required_custom, get_current_user_data
import base64
import io

face_bp = Blueprint('face', __name__, url_prefix='/face')

@face_bp.route('/register', methods=['POST'])
@jwt_required_custom
def register_face():
    """
    Register face for mahasiswa
    
    Request body:
    {
        "nim": "string",
        "face_image": "base64 string or file"
    }
    """
    try:
        user_data = get_current_user_data()
        
        # Can be called by mahasiswa or admin
        if user_data.get('level') not in ['mahasiswa', 'admin']:
            return jsonify({'error': 'Unauthorized'}), 403
        
        # Get data
        if request.content_type and 'multipart/form-data' in request.content_type:
            # File upload
            if 'face_image' not in request.files:
                return jsonify({'error': 'Face image is required'}), 400
            
            face_image = request.files['face_image']
            nim = request.form.get('nim')
        else:
            # JSON with base64
            data = request.get_json()
            if not data or 'face_image' not in data:
                return jsonify({'error': 'Face image is required'}), 400
            
            face_image = data['face_image']
            nim = data.get('nim')
        
        # If mahasiswa, use their own NIM
        if user_data.get('level') == 'mahasiswa':
            nim = user_data.get('nim')
        
        if not nim:
            return jsonify({'error': 'NIM is required'}), 400
        
        # Check if already registered
        if FaceService.get_registered_status(nim):
            return jsonify({'error': 'Face already registered for this student'}), 400
        
        # Encode face
        success, encoding_or_error = FaceService.encode_face_from_image(face_image)
        
        if not success:
            return jsonify({'error': encoding_or_error}), 400
        
        # Save encoding
        if FaceService.save_face_encoding(nim, encoding_or_error):
            return jsonify({
                'message': 'Face registered successfully',
                'nim': nim
            }), 200
        
        return jsonify({'error': 'Failed to save face encoding'}), 500
        
    except Exception as e:
        return jsonify({'error': f'Face registration failed: {str(e)}'}), 500

@face_bp.route('/verify', methods=['POST'])
@jwt_required_custom
def verify_face():
    """
    Verify face for attendance
    
    Request body:
    {
        "nim": "string",
        "face_image": "base64 string or file"
    }
    """
    try:
        user_data = get_current_user_data()
        
        # Get data
        if request.content_type and 'multipart/form-data' in request.content_type:
            if 'face_image' not in request.files:
                return jsonify({'error': 'Face image is required'}), 400
            
            face_image = request.files['face_image']
            nim = request.form.get('nim') or user_data.get('nim')
        else:
            data = request.get_json()
            if not data or 'face_image' not in data:
                return jsonify({'error': 'Face image is required'}), 400
            
            face_image = data['face_image']
            nim = data.get('nim') or user_data.get('nim')
        
        if not nim:
            return jsonify({'error': 'NIM is required'}), 400
        
        # Verify face
        success, confidence_or_error = FaceService.verify_face(nim, face_image)
        
        if success:
            return jsonify({
                'message': 'Face verified successfully',
                'confidence': confidence_or_error,
                'nim': nim
            }), 200
        
        return jsonify({
            'error': confidence_or_error,
            'verified': False
        }), 400
        
    except Exception as e:
        return jsonify({'error': f'Face verification failed: {str(e)}'}), 500

@face_bp.route('/status/<nim>', methods=['GET'])
@jwt_required_custom
def get_face_status(nim):
    """Check if student has registered face"""
    try:
        is_registered = FaceService.get_registered_status(nim)
        return jsonify({
            'nim': nim,
            'face_registered': is_registered
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
