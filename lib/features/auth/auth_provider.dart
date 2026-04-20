import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<bool> login(String employeeId, String password) async {
    if (employeeId.isEmpty || password.isEmpty) {
      state = state.copyWith(isLoading: false, error: 'Please enter credentials');
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 500));
    final user = User(
      id: employeeId,
      name: 'Demo User',
      email: '$employeeId@genmindz.in',
      role: UserRole.employee,
      token: 'mock-token',
    );
    state = state.copyWith(user: user, isLoading: false);
    return true;
  }

  void setUser(User user) => state = state.copyWith(user: user);

  void logout() => state = AuthState();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
