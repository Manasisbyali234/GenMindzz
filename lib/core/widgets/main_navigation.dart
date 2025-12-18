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
      floatingActionButton: user.role == UserRole.security ? _buildQRScanButton(context) : null,
      floatingActionButtonLocation: user.role == UserRole.security 
          ? FloatingActionButtonLocation.centerDocked 
          : null,
    );
  }

  Widget _buildBottomNavigation(BuildContext context, UserRole role) {
    if (role == UserRole.security) {
      return BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppColors.cardBackground,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0, context, role),
              _buildNavItem(Icons.person, 'Profile', 1, context, role),
            ],
          ),
        ),
      );
    } else {
      return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _getCurrentIndex(context, role),
        onTap: (index) => _onTap(context, index, role),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Visitors'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      );
    }
  }

  Widget _buildNavItem(IconData icon, String label, int index, BuildContext context, UserRole role) {
    final isSelected = _getCurrentIndex(context, role) == index;
    return GestureDetector(
      onTap: () => _onTap(context, index, role),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRScanButton(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => context.go('/scanner'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.qr_code_scanner,
          color: AppColors.textLight,
          size: 28,
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