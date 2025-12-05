import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;
  
  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });
  
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(AuthState()) {
    checkAuthStatus();
  }
  
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    final isLoggedIn = await _authService.isLoggedIn();
    
    if (isLoggedIn) {
      final isValid = await _authService.verifyToken();
      
      if (isValid) {
        final user = await _authService.getUserData();
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      } else {
        await logout();
      }
    } else {
      state = state.copyWith(isLoading: false);
    }
  }
  
  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _authService.login(username, password);
    
    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result['user'],
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['error'],
      );
      return false;
    }
  }
  
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }

  // Update user name locally (for profile edit)
  void updateUserName(String newName) {
    if (state.user != null) {
      final updatedUser = UserModel(
        idUser: state.user!.idUser,
        username: state.user!.username,
        nama: newName,
        level: state.user!.level,
        nim: state.user!.nim,
        nip: state.user!.nip,
      );
      state = state.copyWith(user: updatedUser);
    }
  }
}
