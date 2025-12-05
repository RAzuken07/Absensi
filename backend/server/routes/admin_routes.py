from flask import Blueprint, request, jsonify
from utils.jwt_auth import admin_required
from services.admin_service import AdminService

admin_bp = Blueprint('admin', __name__, url_prefix='/admin')

# ============ DOSEN ROUTES ============

@admin_bp.route('/dosen', methods=['GET'])
@admin_required
def get_all_dosen():
    """Get all dosen"""
    try:
        dosen_list = AdminService.get_all_dosen()
        return jsonify({'data': dosen_list}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/dosen/<nip>', methods=['GET'])
@admin_required
def get_dosen(nip):
    """Get dosen by NIP"""
    try:
        dosen = AdminService.get_dosen_by_nip(nip)
        if dosen:
            return jsonify({'data': dosen}), 200
        return jsonify({'error': 'Dosen not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/dosen', methods=['POST'])
@admin_required
def create_dosen():
    """Create new dosen"""
    try:
        data = request.get_json()
        success, message = AdminService.create_dosen(data)
        
        if success:
            return jsonify({'message': message}), 201
        return jsonify({'error': message}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/dosen/<nip>', methods=['PUT'])
@admin_required
def update_dosen(nip):
    """Update dosen"""
    try:
        data = request.get_json()
        success, message = AdminService.update_dosen(nip, data)
        
        if success:
            return jsonify({'message': message}), 200
        return jsonify({'error': message}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/dosen/<nip>', methods=['DELETE'])
@admin_required
def delete_dosen(nip):
    """Delete dosen"""
    try:
        success, message = AdminService.delete_dosen(nip)
        
        if success:
            return jsonify({'message': message}), 200
        return jsonify({'error': message}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ============ MAHASISWA ROUTES ============

@admin_bp.route('/mahasiswa', methods=['GET'])
@admin_required
def get_all_mahasiswa():
    """Get all mahasiswa"""
    try:
        mahasiswa_list = AdminService.get_all_mahasiswa()
        return jsonify({'data': mahasiswa_list}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/mahasiswa/<nim>', methods=['GET'])
@admin_required
def get_mahasiswa(nim):
    """Get mahasiswa by NIM"""
    try:
        mahasiswa = AdminService.get_mahasiswa_by_nim(nim)
        if mahasiswa:
            return jsonify({'data': mahasiswa}), 200
        return jsonify({'error': 'Mahasiswa not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/mahasiswa', methods=['POST'])
@admin_required
def create_mahasiswa():
    """Create new mahasiswa"""
    try:
        data = request.get_json()
        success, message = AdminService.create_mahasiswa(data)
        
        if success:
            return jsonify({'message': message}), 201
        return jsonify({'error': message}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/mahasiswa/<nim>', methods=['PUT'])
@admin_required
def update_mahasiswa(nim):
    """Update mahasiswa"""
    try:
        data = request.get_json()
        success, message = AdminService.update_mahasiswa(nim, data)
        
        if success:
            return jsonify({'message': message}), 200
        return jsonify({'error': message}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/mahasiswa/<nim>', methods=['DELETE'])
@admin_required
def delete_mahasiswa(nim):
    """Delete mahasiswa"""
    try:
        success, message = AdminService.delete_mahasiswa(nim)
        
        if success:
            return jsonify({'message': message}), 200
        return jsonify({'error': message}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ============ MATA KULIAH ROUTES ============

@admin_bp.route('/matakuliah', methods=['GET'])
@admin_required
def get_all_matakuliah():
    """Get all mata kuliah"""
    try:
        matakuliah_list = AdminService.get_all_matakuliah()
        return jsonify({'data': matakuliah_list}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/matakuliah/<int:id_matakuliah>', methods=['GET'])
@admin_required
def get_matakuliah(id_matakuliah):
    """Get mata kuliah by ID"""
    try:
        matakuliah = AdminService.get_matakuliah_by_id(id_matakuliah)
        if matakuliah:
            return jsonify({'data': matakuliah}), 200
        return jsonify({'error': 'Mata kuliah not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/matakuliah', methods=['POST'])
@admin_required
def create_matakuliah():
    """Create new mata kuliah"""
    try:
        data = request.get_json()
        success, message = AdminService.create_matakuliah(data)
        
        if success:
            return jsonify({'message': message}), 201
        return jsonify({'error': message}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/matakuliah/<int:id_matakuliah>', methods=['PUT'])
@admin_required
def update_matakuliah(id_matakuliah):
    """Update mata kuliah"""
    try:
        data = request.get_json()
        success, message = AdminService.update_matakuliah(id_matakuliah, data)
        
        if success:
            return jsonify({'message': message}), 200
        return jsonify({'error': message}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/matakuliah/<int:id_matakuliah>', methods=['DELETE'])
@admin_required
def delete_matakuliah(id_matakuliah):
    """Delete mata kuliah"""
    try:
        success, message = AdminService.delete_matakuliah(id_matakuliah)
        
        if success:
            return jsonify({'message': message}), 200
        return jsonify({'error': message}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ============ KELAS ROUTES ============

@admin_bp.route('/kelas', methods=['GET'])
@admin_required
def get_all_kelas():
    """Get all kelas"""
    try:
        kelas_list = AdminService.get_all_kelas()
        return jsonify({'data': kelas_list}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/kelas/<int:id_kelas>', methods=['GET'])
@admin_required
def get_kelas(id_kelas):
    """Get kelas by ID"""
    try:
        kelas = AdminService.get_kelas_by_id(id_kelas)
        if kelas:
            return jsonify({'data': kelas}), 200
        return jsonify({'error': 'Kelas not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/kelas', methods=['POST'])
@admin_required
def create_kelas():
    """Create new kelas"""
    try:
        data = request.get_json()
        success, message = AdminService.create_kelas(data)
        
        if success:
            return jsonify({'message': message}), 201
        return jsonify({'error': message}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/kelas/<int:id_kelas>', methods=['PUT'])
@admin_required
def update_kelas(id_kelas):
    """Update kelas"""
    try:
        data = request.get_json()
        success, message = AdminService.update_kelas(id_kelas, data)
        
        if success:
            return jsonify({'message': message}), 200
        return jsonify({'error': message}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/kelas/<int:id_kelas>', methods=['DELETE'])
@admin_required
def delete_kelas(id_kelas):
    """Delete kelas"""
    try:
        success, message = AdminService.delete_kelas(id_kelas)
        
        if success:
            return jsonify({'message': message}), 200
        return jsonify({'error': message}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ============ KELAS-DOSEN ASSIGNMENT ROUTES ============

@admin_bp.route('/kelas-dosen', methods=['POST'])
@admin_required
def assign_dosen_to_kelas():
    """Assign dosen to kelas"""
    try:
        data = request.get_json()
        print(f"[ROUTE DEBUG] Received request data: {data}")
        print(f"[ROUTE DEBUG] Data type: {type(data)}")
        print(f"[ROUTE DEBUG] Data keys: {data.keys() if data else 'None'}")
        
        success, message = AdminService.assign_dosen_to_kelas(data)
        
        print(f"[ROUTE DEBUG] Service returned - success: {success}, message: {message}")
        
        if success:
            return jsonify({'message': message}), 201
        return jsonify({'error': message}), 400
    except Exception as e:
        print(f"[ROUTE ERROR] Exception in route: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/kelas/<int:id_kelas>/dosen', methods=['GET'])
@admin_required
def get_dosen_by_kelas(id_kelas):
    """Get all dosen teaching a kelas"""
    try:
        dosen_list = AdminService.get_dosen_by_kelas(id_kelas)
        return jsonify({'data': dosen_list}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/kelas-dosen/<int:id_kelas_dosen>', methods=['DELETE'])
@admin_required
def remove_dosen_from_kelas(id_kelas_dosen):
    """Remove dosen from kelas"""
    try:
        success, message = AdminService.remove_dosen_from_kelas(id_kelas_dosen)
        
        if success:
            return jsonify({'message': message}), 200
        return jsonify({'error': message}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500
