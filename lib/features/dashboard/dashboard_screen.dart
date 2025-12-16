import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/visitor.dart';
import '../visitors/visitors_provider.dart';
import '../auth/auth_provider.dart';
import '../../models/user.dart';
import 'widgets/invite_visitor_modal.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final visitors = ref.watch(visitorsProvider);

    if (user?.role == UserRole.employee) {
      return _buildEmployeeDashboard(context, visitors);
    } else {
      return _buildSecurityDashboard(context, visitors);
    }
  }

  Widget _buildEmployeeDashboard(BuildContext context, List<Visitor> visitors) {
    final todayVisitors = visitors.where((v) => 
      v.visitTime.day == DateTime.now().day).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Visitors')),
      body: Column(
        children: [
          _buildTodayHeader(todayVisitors.length),
          _buildTimelineIndicator(),
          Expanded(child: _buildAppointmentsList(todayVisitors)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInviteVisitorModal(context),
        icon: const Icon(Icons.add),
        label: const Text('Invite Visitor'),
      ),
    );
  }

  Widget _buildSecurityDashboard(BuildContext context, List<Visitor> visitors) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatsCards(visitors),
            const SizedBox(height: 24),
            _buildRecentActivity(visitors),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Today's Appointments",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTimelineItem('Expected', AppColors.pending, true),
          _buildTimelineItem('Arrived', AppColors.approved, false),
          _buildTimelineItem('Checked-in', AppColors.checkedIn, false),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String label, Color color, bool isActive) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive ? color : color.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? color : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<Visitor> visitors) {
    if (visitors.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('No appointments today', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visitors.length,
      itemBuilder: (context, index) => _buildAppointmentCard(visitors[index]),
    );
  }

  Widget _buildAppointmentCard(Visitor visitor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  visitor.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${visitor.visitTime.hour}:${visitor.visitTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Department: ${visitor.department}'),
            Text('Purpose: ${visitor.purpose}'),
            const SizedBox(height: 8),
            const Text(
              '← Swipe for actions',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(List<Visitor> visitors) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Visitors', '${visitors.length}', Icons.people)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Checked In', '${visitors.where((v) => v.status == VisitorStatus.checkedIn).length}', Icons.check_circle)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(List<Visitor> visitors) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: visitors.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: CircleAvatar(
                      child: Text(visitors[index].name[0]),
                    ),
                    title: Text(visitors[index].name),
                    subtitle: Text(visitors[index].purpose),
                    trailing: Text(visitors[index].status.name),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInviteVisitorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const InviteVisitorModal(),
    );
  }
}