from flask import Blueprint, request, jsonify
from utils.jwt_auth import mahasiswa_required, jwt_required_custom, get_current_user_data
from services.absensi_service import AbsensiService

absensi_bp = Blueprint('absensi', __name__, url_prefix='/absensi')

@absensi_bp.route('/submit', methods=['POST'])
@mahasiswa_required
def submit_absensi():
    """
    Submit attendance
    
    Request body:
    {
        "id_sesi": int,
        "qr_data": dict/string (scanned QR code data),
        "face_image": base64 string,
        "latitude": float,
        "longitude": float
    }
    """
    try:
        user_data = get_current_user_data()
        nim = user_data.get('nim')
        
        if not nim:
            return jsonify({'error': 'NIM not found in token'}), 400
        
        data = request.get_json()
        
        # Add NIM to data
        data['nim'] = nim
        
        # Validate required fields
        required_fields = ['id_sesi', 'qr_data', 'face_image', 'latitude', 'longitude']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'{field} is required'}), 400
        
        # Submit attendance
        success, result = AbsensiService.submit_absensi(data)
        
        if success:
            return jsonify({
                'message': 'Attendance submitted successfully',
                'data': result
            }), 200
        
        return jsonify({'error': result}), 400
        
    except Exception as e:
        return jsonify({'error': f'Failed to submit attendance: {str(e)}'}), 500

@absensi_bp.route('/sesi/<int:id_sesi>', methods=['GET'])
@jwt_required_custom
def get_sesi_info(id_sesi):
    """Get session information"""
    try:
        sesi = AbsensiService.get_session_info(id_sesi)
        
        if sesi:
            return jsonify({'data': sesi}), 200
        return jsonify({'error': 'Session not found'}), 404
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@absensi_bp.route('/active-sessions', methods=['GET'])
@mahasiswa_required
def get_active_sessions():
    """Get active sessions for student's classes"""
    try:
        user_data = get_current_user_data()
        nim = user_data.get('nim')
        
        if not nim:
            return jsonify({'error': 'NIM not found in token'}), 400
        
        sessions = AbsensiService.get_active_sessions_for_student(nim)
        return jsonify({'data': sessions}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@absensi_bp.route('/my-matakuliah', methods=['GET'])
@mahasiswa_required
def get_my_matakuliah():
    """Get mata kuliah list for mahasiswa based on their kelas"""
    try:
        user_data = get_current_user_data()
        nim = user_data.get('nim')
        
        if not nim:
            return jsonify({'error': 'NIM not found in token'}), 400
        
        # Get mahasiswa's kelas
        from database.db import Database
        query_mahasiswa = "SELECT id_kelas FROM mahasiswa WHERE nim = %s"
        mahasiswa = Database.execute_query(query_mahasiswa, (nim,), fetch_one=True)
        
        print(f"[DEBUG] Mahasiswa data for NIM {nim}: {mahasiswa}")
        
        if not mahasiswa or not mahasiswa.get('id_kelas'):
            print(f"[DEBUG] Mahasiswa tidak memiliki kelas yang di-assign")
            return jsonify({'error': 'Kelas not found', 'data': []}), 200
        
        id_kelas = mahasiswa['id_kelas']
        print(f"[DEBUG] ID Kelas mahasiswa: {id_kelas}")
        
        # Get mata kuliah for the kelas
        query_matakuliah = """
            SELECT DISTINCT 
                mk.id_matakuliah,
                mk.kode_mk,
                mk.nama_matakuliah as nama_mk,
                mk.sks,
                k.nama_kelas,
                d.nama as nama_dosen
            FROM kelas k
            JOIN kelas_dosen kd ON k.id_kelas = kd.id_kelas
            JOIN dosen d ON kd.nip_dosen = d.nip
            JOIN matakuliah mk ON kd.id_matakuliah = mk.id_matakuliah
            WHERE k.id_kelas = %s
            ORDER BY mk.nama_matakuliah
        """
        
        print(f"[DEBUG] Executing query with id_kelas: {id_kelas}")
        matakuliah_list = Database.execute_query(query_matakuliah, (id_kelas,), fetch_all=True)
        print(f"[DEBUG] Mata kuliah found: {len(matakuliah_list) if matakuliah_list else 0}")
        print(f"[DEBUG] Mata kuliah data: {matakuliah_list}")
        
        return jsonify({'data': matakuliah_list or []}), 200
        
    except Exception as e:
        print(f"[ERROR] Exception in get_my_matakuliah: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

@absensi_bp.route('/history', methods=['GET'])
@mahasiswa_required
def get_history():
    """Get attendance history for student"""
    try:
        user_data = get_current_user_data()
        nim = user_data.get('nim')
        
        if not nim:
            return jsonify({'error': 'NIM not found in token'}), 400
        
        history = AbsensiService.get_history(nim)
        return jsonify({'data': history}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@absensi_bp.route('/statistics', methods=['GET'])
@mahasiswa_required
def get_statistics():
    """Get attendance statistics for student"""
    try:
        user_data = get_current_user_data()
        nim = user_data.get('nim')
        
        if not nim:
            return jsonify({'error': 'NIM not found in token'}), 400
        
        stats = AbsensiService.get_statistics(nim)
        return jsonify({'data': stats}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@absensi_bp.route('/check/<int:id_pertemuan>', methods=['GET'])
@mahasiswa_required
def check_attendance(id_pertemuan):
    """Check if student has already submitted attendance for a pertemuan"""
    try:
        user_data = get_current_user_data()
        nim = user_data.get('nim')
        
        if not nim:
            return jsonify({'error': 'NIM not found in token'}), 400
        
        already_absent = AbsensiService.check_already_absent(nim, id_pertemuan)
        
        return jsonify({
            'already_absent': already_absent,
            'nim': nim,
            'id_pertemuan': id_pertemuan
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@absensi_bp.route('/face/register', methods=['POST'])
@mahasiswa_required
def register_face():
    """Register mahasiswa face for verification"""
    try:
        if 'face_image' not in request.files:
            return jsonify({'error': 'No face image provided'}), 400
        
        face_image = request.files['face_image']
        user_data = get_current_user_data()
        nim = user_data.get('nim')
        
        if not nim:
            return jsonify({'error': 'NIM not found'}), 400
        
        # Save face image to filesystem
        import os
        upload_folder = os.path.join('uploads', 'faces', 'mahasiswa')
        os.makedirs(upload_folder, exist_ok=True)
        
        filename = f"{nim}.jpg"
        filepath = os.path.join(upload_folder, filename)
        face_image.save(filepath)
        
        return jsonify({'message': 'Wajah berhasil didaftarkan'}), 200
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@absensi_bp.route('/face/verify', methods=['POST'])
@mahasiswa_required
def verify_face():
    """Verify mahasiswa face during attendance"""
    try:
        if 'face_image' not in request.files:
            return jsonify({'error': 'No face image provided'}), 400
        
        face_image = request.files['face_image']
        user_data = get_current_user_data()
        nim = user_data.get('nim')
        
        if not nim:
            return jsonify({'error': 'NIM not found'}), 400
        
        # Check if registered face exists
        import os
        registered_face_path = os.path.join('uploads', 'faces', 'mahasiswa', f"{nim}.jpg")
        
        if not os.path.exists(registered_face_path):
            return jsonify({'error': 'Wajah belum didaftarkan. Silakan daftar wajah terlebih dahulu.'}), 400
        
        # Simple verification: just check if file exists for now
        # TODO: Implement actual face recognition comparison
        return jsonify({'message': 'Verifikasi berhasil'}), 200
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500
