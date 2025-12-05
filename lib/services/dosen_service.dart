import 'dart:io';
import 'package:dio/dio.dart';
import '../models/sesi_model.dart';
import '../models/kelas_model.dart';
import 'api_service.dart';

class DosenService {
  final ApiService _apiService = ApiService();
  
  // Register Face for Dosen
  Future<Map<String, dynamic>> registerFace(File faceImage) async {
    try {
      String fileName = faceImage.path.split('/').last;
      final requestData = FormData.fromMap({
        'face_image': await MultipartFile.fromFile(
          faceImage.path,
          filename: fileName,
        ),
      });

      final response = await _apiService.post(
        '/dosen/face/register',
        data: requestData,
      );

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Gagal upload wajah',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Verify Face for Dosen (before opening session)
  Future<Map<String, dynamic>> verifyFace(File faceImage) async {
    try {
      String fileName = faceImage.path.split('/').last;
      final requestData = FormData.fromMap({
        'face_image': await MultipartFile.fromFile(
          faceImage.path,
          filename: fileName,
        ),
      });

      final response = await _apiService.post(
        '/dosen/face/verify',
        data: requestData,
      );

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Verifikasi berhasil',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Verifikasi gagal',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  Future<List<KelasModel>> getKelas() async {
    try {
      final response = await _apiService.get('/dosen/kelas');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => KelasModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting kelas: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> openSesi(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/dosen/open-sesi', data: data);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }
      
      return {
        'success': false,
        'error': response.data['error'] ?? 'Failed to open session',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Get pertemuan status - which pertemuan have sessions created
  Future<List<int>> getPertemuanStatus(int idKelas) async {
    try {
      final response = await _apiService.get('/dosen/pertemuan-status/$idKelas');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map<int>((item) => item['pertemuan_ke'] as int).toList();
      }
      return [];
    } catch (e) {
      print('Error getting pertemuan status: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> closeSesi(int idSesi) async {
    try {
      final response = await _apiService.post('/dosen/close-sesi/$idSesi');
      
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
  
  Future<List<dynamic>> getRekap(int idKelas) async {
    try {
      final response = await _apiService.get('/dosen/rekap/$idKelas');
      
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return [];
    } catch (e) {
      print('Error getting rekap: $e');
      return [];
    }
  }
  
  Future<List<SesiModel>> getActiveSessions() async {
    try {
      final response = await _apiService.get('/dosen/active-sessions');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => SesiModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting active sessions: $e');
      return [];
    }
  }
  
  // Get Pertemuan by Kelas
  Future<List<Map<String, dynamic>>> getPertemuanByKelas(int idKelas) async {
    try {
      final response = await _apiService.get('/dosen/pertemuan/$idKelas');
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error getting pertemuan: $e');
      return [];
    }
  }
  
  // Get Absensi Detail by Pertemuan
  Future<List<Map<String, dynamic>>> getAbsensiByPertemuan(int idPertemuan) async {
    try {
      final response = await _apiService.get('/dosen/absensi/pertemuan/$idPertemuan');
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error getting absensi detail: $e');
      return [];
    }
  }
}
