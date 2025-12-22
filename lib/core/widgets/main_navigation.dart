import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_provider.dart';
import '../../models/user.dart';
import '../constants/app_colors.dart';

class MainNavigation extends ConsumerWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigation(context, user.role),
      floatingActionButton: _buildFloatingActionButton(context, user.role),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavigation(BuildContext context, UserRole role) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', 0, context, role),
              _buildNavItem(Icons.notifications_outlined, 'Alerts', 1, context, role),
              const SizedBox(width: 60), // Space for FAB
              _buildNavItem(Icons.person_outline, 'Profile', role == UserRole.security ? 1 : 3, context, role),
              _buildNavItem(Icons.logout, 'Exit', role == UserRole.security ? 1 : 4, context, role),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int targetIndex, BuildContext context, UserRole role) {
    final currentIndex = _getCurrentIndex(context, role);
    final isSelected = _isNavItemSelected(label, context, role);
    
    return GestureDetector(
      onTap: () => _onNavItemTap(label, context, role),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? const Color(0xFF1C88E5) : const Color(0xFF9FB6C5),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? const Color(0xFF1C88E5) : const Color(0xFF9FB6C5),
            ),
          ),
        ],
      ),
    );
  }

  bool _isNavItemSelected(String label, BuildContext context, UserRole role) {
    final location = GoRouterState.of(context).uri.path;
    switch (label) {
      case 'Home':
        return location == '/dashboard' || location == '/scanner';
      case 'Alerts':
        return location == '/notifications';
      case 'Profile':
        return location == '/profile';
      case 'Exit':
        return false;
      default:
        return false;
    }
  }

  void _onNavItemTap(String label, BuildContext context, UserRole role) {
    switch (label) {
      case 'Home':
        if (role == UserRole.security) {
          context.go('/scanner');
        } else {
          context.go('/dashboard');
        }
        break;
      case 'Alerts':
        context.go('/notifications');
        break;
      case 'Profile':
        context.go('/profile');
        break;
      case 'Exit':
        context.go('/');
        break;
    }
  }

  Widget _buildFloatingActionButton(BuildContext context, UserRole role) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          if (role == UserRole.security) {
            context.go('/scanner');
          } else {
            // Open invite modal for employees
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(
          role == UserRole.security ? Icons.qr_code_scanner : Icons.person_add,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  int _getCurrentIndex(BuildContext context, UserRole role) {
    final location = GoRouterState.of(context).uri.path;
    
    if (role == UserRole.security) {
      switch (location) {
        case '/dashboard':
          return 0;
        case '/profile':
          return 1;
        default:
          return 0;
      }
    } else {
      switch (location) {
        case '/dashboard':
          return 0;
        case '/visitors':
          return 1;
        case '/notifications':
          return 2;
        case '/profile':
          return 3;
        default:
          return 0;
      }
    }
  }

  void _onTap(BuildContext context, int index, UserRole role) {
    if (role == UserRole.security) {
      switch (index) {
        case 0:
          context.go('/dashboard');
          break;
        case 1:
          context.go('/profile');
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.go('/dashboard');
          break;
        case 1:
          context.go('/visitors');
          break;
        case 2:
          context.go('/notifications');
          break;
        case 3:
          context.go('/profile');
          break;
      }
    }
  }
}