import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config/constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Save token
        await _apiService.setToken(data['access_token']);
        
        // Save refresh token if available
        if (data['refresh_token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            AppConstants.refreshTokenKey,
            data['refresh_token'],
          );
        }
        
        // Save user data
        await saveUserData(UserModel.fromJson(data['user']));
        
        // Set logged in flag
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.isLoggedInKey, true);
        
        return {
          'success': true,
          'user': UserModel.fromJson(data['user']),
        };
      }
      
      return {
        'success': false,
        'error': 'Login failed',
      };
    } on DioException catch (e) {
      String errorMessage = 'Login gagal';
      
      // Extract error message from response
      if (e.response != null && e.response!.data != null) {
        if (e.response!.data is Map && e.response!.data['error'] != null) {
          errorMessage = e.response!.data['error'];
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Koneksi timeout';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Tidak dapat terhubung ke server';
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
  
  Future<void> saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.userDataKey,
      jsonEncode(user.toJson()),
    );
  }
  
  Future<UserModel?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(AppConstants.userDataKey);
      
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        return UserModel.fromJson(userData);
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return null;
  }
  
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.isLoggedInKey) ?? false;
  }
  
  Future<bool> verifyToken() async {
    try {
      await _apiService.loadToken();
      final response = await _apiService.get(AppConstants.verifyTokenEndpoint);
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> logout() async {
    await _apiService.clearToken();
  }
}
