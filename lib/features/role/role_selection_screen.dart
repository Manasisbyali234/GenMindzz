import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../../models/user.dart';
import '../../mock_data/mock_data.dart';
import '../../core/constants/app_colors.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Shield Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.shield,
                  size: 40,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 24),
              // App Name
              const Text(
                'GateKeeper AI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              const Text(
                'Visitor Management System',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 60),
              // Role Cards
              _buildRoleCard(
                title: 'Security Portal',
                subtitle: 'Monitor and manage visitor access',
                icon: Icons.security,
                role: UserRole.security,
              ),
              const SizedBox(height: 20),
              _buildRoleCard(
                title: 'Employee App',
                subtitle: 'Invite and manage your visitors',
                icon: Icons.business_center,
                role: UserRole.employee,
              ),
              const Spacer(),
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedRole != null ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required UserRole role,
  }) {
    final isSelected = selectedRole == role;
    
    return SizedBox(
      width: double.infinity,
      child: Material(
        elevation: isSelected ? 8 : 4,
        borderRadius: BorderRadius.circular(16),
        shadowColor: Colors.black12,
        child: InkWell(
          onTap: () => setState(() => selectedRole = role),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isSelected ? AppColors.primaryGradient : null,
              color: isSelected ? null : AppColors.cardBackground,
              border: isSelected
                  ? null
                  : Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.textLight.withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? AppColors.textLight : AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.textLight : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected 
                              ? AppColors.textLight.withOpacity(0.8)
                              : AppColors.textLight.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
                  color: isSelected ? AppColors.textLight : AppColors.textSecondary,
                  size: isSelected ? 24 : 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    if (selectedRole != null) {
      final user = selectedRole == UserRole.security
          ? MockData.securityUser
          : MockData.employeeUser;
      
      ref.read(authProvider.notifier).setUser(user);
      
      if (selectedRole == UserRole.security) {
        context.go('/scanner');
      } else {
        context.go('/dashboard');
      }
    }
  }
}