import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/api_service.dart';
import '../../models/user.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<bool> login(
    String email,
    String password,
    String captchaToken,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Please enter your email and password.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await ApiService.login(
        email: email.trim(),
        password: password,
        captchaToken: captchaToken,
      );

      var user = result.user;

      try {
        user = await ApiService.getCurrentUser(result.token);
      } on ApiException {
        user = result.user;
      }

      if (user.token == null || user.token!.isEmpty) {
        user = user.copyWith(token: result.token);
      }

      state = state.copyWith(
        user: user,
        isLoading: false,
        error: null,
      );
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, error: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to sign in. Check the API server and try again.',
      );
      return false;
    }
  }

  Future<void> refreshProfile({bool showLoader = false}) async {
    final token = state.user?.token;
    if (token == null || token.isEmpty) {
      return;
    }

    if (showLoader) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final refreshedUser = await ApiService.getCurrentUser(token);
      state = state.copyWith(
        user: refreshedUser.copyWith(token: token),
        isLoading: false,
        error: null,
      );
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, error: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to refresh profile details.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void setUser(User user) {
    state = state.copyWith(user: user, error: null);
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
