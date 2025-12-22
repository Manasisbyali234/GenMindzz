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
    
    UserRole? role;
    String? name;
    
    if (employeeId == 'SEC001' && password == 'Security@123') {
      role = UserRole.security;
      name = 'Security Officer';
    } else if (employeeId == 'EMP001' && password == 'Employee@123') {
      role = UserRole.employee;
      name = 'Employee';
    }
    
    if (role != null && name != null) {
      final user = User(
        id: employeeId,
        name: name,
        email: '${employeeId.toLowerCase()}@company.com',
        role: role,
      );
      state = state.copyWith(user: user, isLoading: false);
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