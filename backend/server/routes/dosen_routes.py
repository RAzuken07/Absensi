from flask import Blueprint, request, jsonify
from utils.jwt_auth import dosen_required, get_current_user_data
from services.dosen_service import DosenService
import os

dosen_bp = Blueprint('dosen', __name__, url_prefix='/dosen')

@dosen_bp.route('/kelas', methods=['GET'])
@dosen_required
def get_kelas():
    """Get all kelas taught by dosen"""
    try:
        user_data = get_current_user_data()
        nip = user_data.get('nip')
        
        if not nip:
            return jsonify({'error': 'NIP not found in token'}), 400
        
        kelas_list = DosenService.get_kelas_by_dosen(nip)
        return jsonify({'data': kelas_list}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@dosen_bp.route('/pertemuan/<int:id_kelas>', methods=['GET'])
@dosen_required
def get_pertemuan(id_kelas):
    """Get pertemuan for a kelas"""
    try:
        pertemuan_list = DosenService.get_pertemuan_by_kelas(id_kelas)
        return jsonify({'data': pertemuan_list}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@dosen_bp.route('/pertemuan-status/<int:id_kelas>', methods=['GET'])
@dosen_required
def get_pertemuan_status(id_kelas):
    """Get status of which pertemuan have sessions created"""
    try:
        status_list = DosenService.get_pertemuan_status_by_kelas(id_kelas)
        return jsonify({'data': status_list}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@dosen_bp.route('/absensi/pertemuan/<int:id_pertemuan>', methods=['GET'])
@dosen_required
def get_absensi_by_pertemuan(id_pertemuan):
    """Get absensi details for a specific pertemuan"""
    try:
        absensi_list = DosenService.get_absensi_by_pertemuan(id_pertemuan)
        return jsonify({'data': absensi_list}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@dosen_bp.route('/pertemuan', methods=['POST'])
@dosen_required
def create_pertemuan():
    """Create new pertemuan"""
    try:
        data = request.get_json()
        success, result = DosenService.create_pertemuan(data)
        
        if success:
            return jsonify({'message': 'Pertemuan created', 'id_pertemuan': result}), 201
        return jsonify({'error': result}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@dosen_bp.route('/open-sesi', methods=['POST'])
@dosen_required
def open_sesi():
    """
    Open attendance session (simplified)
    
    Request body:
    {
        "id_kelas": int (required)
    }
    
    Optional fields (will use defaults if not provided):
    - durasi_menit: int (default 90)
    - topik: str (default "Pertemuan ke-X")
    - lokasi_lat: float (default PNL campus)
    - lokasi_long: float (default PNL campus)
    - radius_meter: int (default 50)
    """
    try:
        user_data = get_current_user_data()
        nip = user_data.get('nip')
        
        if not nip:
            return jsonify({'error': 'NIP not found in token'}), 400
        
        data = request.get_json()
        
        # Only id_kelas is required now
        if 'id_kelas' not in data:
            return jsonify({'error': 'id_kelas is required'}), 400
        
        success, result = DosenService.open_sesi_absensi(data, nip)
        
        if success:
            return jsonify({
                'message': 'Session opened successfully',
                'data': result
            }), 201
        return jsonify({'error': result}), 400
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@dosen_bp.route('/close-sesi/<int:id_sesi>', methods=['POST'])
@dosen_required
def close_sesi(id_sesi):
    """Close attendance session"""
    try:
        user_data = get_current_user_data()
        nip = user_data.get('nip')
        
        if not nip:
            return jsonify({'error': 'NIP not found in token'}), 400
        
        success, message = DosenService.close_sesi_absensi(id_sesi, nip)
        
        if success:
            return jsonify({'message': message}), 200
        return jsonify({'error': message}), 400
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@dosen_bp.route('/rekap/<int:id_kelas>', methods=['GET'])
@dosen_required
def get_rekap(id_kelas):
    """Get attendance recap for a class"""
    try:
        rekap = DosenService.get_rekap_kehadiran(id_kelas)
        return jsonify({'data': rekap}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@dosen_bp.route('/active-sessions', methods=['GET'])
@dosen_required
def get_active_sessions():
    """Get active sessions for dosen"""
    try:
        user_data = get_current_user_data()
        nip = user_data.get('nip')
        
        if not nip:
            return jsonify({'error': 'NIP not found in token'}), 400
        
        sessions = DosenService.get_active_sessions(nip)
        return jsonify({'data': sessions}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@dosen_bp.route('/session/<int:id_sesi>', methods=['GET'])
@dosen_required
def get_session_details(id_sesi):
    """Get session details with attendance list"""
    try:
        session_data = DosenService.get_session_details(id_sesi)
        
        if session_data:
            return jsonify({'data': session_data}), 200
        return jsonify({'error': 'Session not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@dosen_bp.route('/face/register', methods=['POST'])
@dosen_required
def register_face():
    """Register dosen face for verification"""
    try:
        if 'face_image' not in request.files:
            return jsonify({'error': 'No face image provided'}), 400
        
        face_image = request.files['face_image']
        user_data = get_current_user_data()
        nip = user_data.get('nip')
        
        if not nip:
            return jsonify({'error': 'NIP not found'}), 400
        
        # Save face image to filesystem
        upload_folder = os.path.join('uploads', 'faces', 'dosen')
        os.makedirs(upload_folder, exist_ok=True)
        
        filename = f"{nip}.jpg"
        filepath = os.path.join(upload_folder, filename)
        face_image.save(filepath)
        
        return jsonify({'message': 'Wajah berhasil didaftarkan'}), 200
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@dosen_bp.route('/face/verify', methods=['POST'])
@dosen_required
def verify_face():
    """Verify dosen face before opening session"""
    try:
        if 'face_image' not in request.files:
            return jsonify({'error': 'No face image provided'}), 400
        
        face_image = request.files['face_image']
        user_data = get_current_user_data()
        nip = user_data.get('nip')
        
        if not nip:
            return jsonify({'error': 'NIP not found'}), 400
        
        # Check if registered face exists
        registered_face_path = os.path.join('uploads', 'faces', 'dosen', f"{nip}.jpg")
        
        if not os.path.exists(registered_face_path):
            return jsonify({'error': 'Wajah belum didaftarkan. Silakan daftar wajah terlebih dahulu.'}), 400
        
        # Simple verification: just check if file exists for now
        # TODO: Implement actual face recognition comparison
        return jsonify({'message': 'Verifikasi berhasil'}), 200
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500
