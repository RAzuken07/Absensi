import 'package:dio/dio.dart';
import 'dart:io';
import '../models/sesi_model.dart';
import '../models/absensi_model.dart';
import 'api_service.dart';

class MahasiswaService {
  final ApiService _apiService = ApiService();
  
  Future<List<SesiModel>> getActiveSessions() async {
    try {
      final response = await _apiService.get('/absensi/active-sessions');
      
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
  
  Future<List<Map<String, dynamic>>> getMyMatakuliah() async {
    try {
      final response = await _apiService.get('/absensi/my-matakuliah');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error getting mata kuliah: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> submitAbsensi(
    Map<String, dynamic> data,
    File? faceImage,
  ) async {
    try {
      FormData formData;
      
      if (faceImage != null) {
        // Submit with face image
        String fileName = faceImage.path.split('/').last;
        formData = FormData.fromMap({
          ...data,
          'face_image': await MultipartFile.fromFile(
            faceImage.path,
            filename: fileName,
          ),
        });
      } else {
        formData = FormData.fromMap(data);
      }
      
      final response = await _apiService.post('/absensi/submit', data: formData);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'] ?? 'Absensi berhasil',
        };
      }
      
      return {
        'success': false,
        'message': response.data['error'] ?? 'Failed to submit attendance',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Gagal submit absensi',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  Future<List<AbsensiModel>> getHistory() async {
    try {
      final response = await _apiService.get('/absensi/history');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => AbsensiModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting history: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>?> getStatistics() async {
    try {
      final response = await _apiService.get('/absensi/statistics');
      
      if (response.statusCode == 200) {
        // Backend returns {data: {...}} format
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting statistics: $e');
      return null;
    }
  }
  
  Future<Map<String, dynamic>> registerFace(dynamic faceImage) async {
    try {
      dynamic requestData;
      
      // Support both File and base64 string
      if (faceImage is File) {
        // File upload
        String fileName = faceImage.path.split('/').last;
        requestData = FormData.fromMap({
          'face_image': await MultipartFile.fromFile(
            faceImage.path,
            filename: fileName,
          ),
        });
      } else {
        // Base64 string
        requestData = {
          'face_image': faceImage,
        };
      }
      
      final response = await _apiService.post(
        '/face/register',
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
  
  Future<Map<String, dynamic>> getFaceStatus(String nim) async {
    try {
      final response = await _apiService.get('/face/status/$nim');
      
      if (response.statusCode == 200) {
        return {
          'registered': response.data['face_registered'] ?? false,
        };
      }
      return {' registered': false};
    } catch (e) {
      return {'registered': false};
    }
  }
}
