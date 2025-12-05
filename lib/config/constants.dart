class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://192.168.1.11:5000';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String verifyTokenEndpoint = '/auth/verify';
  static const String refreshTokenEndpoint = '/auth/refresh';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  
  // Face Recognition
  static const double faceRecognitionTolerance = 0.6;
  static const int maxFaceRegistrationAttempts = 3;
  
  // Geolocation
  static const int defaultRadiusMeters = 50;
  static const double campusLatitude = 5.11922;  // Address: kampus PNL 
  static const double campusLongitude = 97.15678;
  
  // Session
  static const int defaultSessionDurationMinutes = 15;
  static const int sessionWarningMinutes = 5;
  
  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const int splashDelaySeconds = 2;
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;
  
  // Image Upload
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
}
