import 'package:dio/dio.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _apiService = ApiService();
  
  // ... (existing methods)
  
  // ============ DOSEN-KELAS ASSIGNMENT ============
  
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
}
