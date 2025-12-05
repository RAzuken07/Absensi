import 'package:dio/dio.dart';
import '../models/dosen_model.dart';
import '../models/mahasiswa_model.dart';
import '../models/matakuliah_model.dart';
import '../models/kelas_model.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _apiService = ApiService();
  
  // ============ DOSEN OPERATIONS ============
  
  Future<List<DosenModel>> getAllDosen() async {
    try {
      final response = await _apiService.get('/admin/dosen');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => DosenModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting dosen: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> createDosen(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/admin/dosen', data: data);
      
      return {
        'success': response.statusCode == 201,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> updateDosen(
    String nip,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.put('/admin/dosen/$nip', data: data);
      
      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> deleteDosen(String nip) async {
    try {
      final response = await _apiService.delete('/admin/dosen/$nip');
      
      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // ============ MAHASISWA OPERATIONS ============
  
  Future<List<MahasiswaModel>> getAllMahasiswa() async {
    try {
      final response = await _apiService.get('/admin/mahasiswa');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => MahasiswaModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting mahasiswa: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> createMahasiswa(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.post('/admin/mahasiswa', data: data);
      
      return {
        'success': response.statusCode == 201,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> updateMahasiswa(
    String nim,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.put('/admin/mahasiswa/$nim', data: data);
      
      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> deleteMahasiswa(String nim) async {
    try {
      final response = await _apiService.delete('/admin/mahasiswa/$nim');
      
      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // ============ MATA KULIAH OPERATIONS ============
  
  Future<List<MataKuliahModel>> getAllMataKuliah() async {
    try {
      final response = await _apiService.get('/admin/matakuliah');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => MataKuliahModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting mata kuliah: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> createMataKuliah(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.post('/admin/matakuliah', data: data);
      
      return {
        'success': response.statusCode == 201,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> updateMataKuliah(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.put(
        '/admin/matakuliah/$id',
        data: data,
      );
      
      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> deleteMataKuliah(int id) async {
    try {
      final response = await _apiService.delete('/admin/matakuliah/$id');
      
      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // ============ KELAS OPERATIONS ============
  
  Future<List<KelasModel>> getAllKelas() async {
    try {
      print('Calling /admin/kelas endpoint...');
      final response = await _apiService.get('/admin/kelas');
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        print('Found ${data.length} kelas');
        final kelasList = data.map((json) => KelasModel.fromJson(json)).toList();
        print('Parsed ${kelasList.length} kelas models');
        return kelasList;
      }
      print('Response not 200, returning empty list');
      return [];
    } on DioException catch (e) {
      print('DioException getting kelas: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
      return [];
    } catch (e, stackTrace) {
      print('Error getting kelas: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> createKelas(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/admin/kelas', data: data);
      
      return {
        'success': response.statusCode == 201,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> updateKelas(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.put('/admin/kelas/$id', data: data);
      
      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> deleteKelas(int id) async {
    try {
      final response = await _apiService.delete('/admin/kelas/$id');
      
      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Gagal hapus kelas',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // ============ KELAS-DOSEN ASSIGNMENT ============
  
  Future<Map<String, dynamic>> assignDosenToKelas(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/admin/kelas-dosen', data: data);
      
      return {
        'success': response.statusCode == 201,
        'message': response.data['message'] ?? 'Success',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Gagal assign dosen',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  Future<List<dynamic>> getDosenByKelas(int idKelas) async {
    try {
      final response = await _apiService.get('/admin/kelas/$idKelas/dosen');
      
      if (response.statusCode == 200) {
        return response.data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting dosen by kelas: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> removeDosenFromKelas(int idKelasDosen) async {
    try {
      final response = await _apiService.delete('/admin/kelas-dosen/$idKelasDosen');
      
      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Gagal hapus assignment',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // ============ KELAS-DOSEN ASSIGNMENT OPERATIONS ============
  
  Future<List<Map<String, dynamic>>> getKelasAssignments(int idKelas) async {
    try {
      final response = await _apiService.get('/admin/kelas/$idKelas/dosen');
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error getting kelas assignments: $e');
      return [];
    }
  }
  
  Future<bool> assignDosenMatakuliah(
    int idKelas,
    String nip,
    int idMatakuliah, {
    String? ruangan,
    String? hari,
    String? jamMulai,
    String? jamSelesai,
  }) async {
    try {
      final data = {
        'id_kelas': idKelas,
        'nip': nip,
        'id_matakuliah': idMatakuliah,
        if (ruangan != null && ruangan.isNotEmpty) 'ruangan': ruangan,
        if (hari != null) 'hari': hari,
        if (jamMulai != null && jamMulai.isNotEmpty) 'jam_mulai': jamMulai,
        if (jamSelesai != null && jamSelesai.isNotEmpty) 'jam_selesai': jamSelesai,
      };

      final response = await _apiService.post('/admin/kelas-dosen', data: data);
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error assigning dosen: $e');
      rethrow;
    }
  }
  
  Future<bool> removeKelasDosen(int id) async {
    try {
      final response = await _apiService.delete('/admin/kelas-dosen/$id');
      return response.statusCode == 200;
    } catch (e) {
      print('Error removing kelas-dosen: $e');
      rethrow;
    }
  }
}
