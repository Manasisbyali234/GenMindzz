import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';


class AuthState {
  final User? user;
  final bool isLoading;

  AuthState({this.user, this.isLoading = false});

  AuthState copyWith({User? user, bool? isLoading}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<bool> login(String employeeId, String password) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1)); // Mock delay
    
    if (employeeId.isNotEmpty && password.isNotEmpty) {
      state = state.copyWith(isLoading: false);
      return true;
    }
    
    state = state.copyWith(isLoading: false);
    return false;
  }

  void setUser(User user) {
    state = state.copyWith(user: user);
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});