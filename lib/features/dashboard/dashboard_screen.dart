import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../models/visitor.dart';
import '../visitors/visitors_provider.dart';
import '../auth/auth_provider.dart';
import '../../models/user.dart';
import 'widgets/invite_visitor_modal.dart';
import '../visitors/widgets/visitor_details_modal.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingSection(todayVisitors.length),
            const SizedBox(height: 24),
            _buildFilterTabs(),
            const SizedBox(height: 20),
            _buildVisitorCards(todayVisitors),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showInviteVisitorModal(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: AppColors.textLight, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSecurityDashboard(BuildContext context, List<Visitor> visitors) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Security Hub'),
        backgroundColor: AppColors.primary,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.go('/notifications'),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.rejected,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '9:00 AM - 6:00 PM',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(visitors),
            const SizedBox(height: 24),
            _buildAIInsightCard(),
            const SizedBox(height: 24),
            _buildSearchAndFilters(),
            const SizedBox(height: 16),
            _buildVisitorsList(visitors),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection(int count) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, John',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          'You have $count visitors today',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterTab('All', true),
          const SizedBox(width: 12),
          _buildFilterTab('Pending Requests', false),
          const SizedBox(width: 12),
          _buildFilterTab('Invited Visitors', false),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.textLight : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildVisitorCards(List<Visitor> visitors) {
    if (visitors.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.calendar_today,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No visitors today',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to invite your first visitor',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visitors.length,
      itemBuilder: (context, index) => _buildVisitorCard(context, visitors[index]),
    );
  }

  Widget _buildVisitorCard(BuildContext context, Visitor visitor) {
    return GestureDetector(
      onTap: () => _showVisitorDetails(context, visitor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    visitor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(visitor.status),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.business, 'Business Meeting'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, 'Today, 2:30 PM'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, 'Conference Room A'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveVisitor(context, visitor),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.approved,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Approve Entry',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _declineVisitor(context, visitor),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.overstay),
                      foregroundColor: AppColors.overstay,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Decline',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rescheduleVisitor(context, visitor),
                    child: const Text(
                      'Reschedule',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _imLate(context, visitor),
                    child: const Text(
                      "I'm Late",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(List<Visitor> visitors) {
    final totalEntries = visitors.length;
    final totalExits = visitors.where((v) => v.status == VisitorStatus.checkedIn).length;
    final onPremises = visitors.where((v) => v.status == VisitorStatus.checkedIn).length;
    final expected = visitors.where((v) => v.status == VisitorStatus.pending).length;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard('Total Entries', '$totalEntries', Icons.login, AppColors.primary),
        _buildStatCard('Total Exits', '$totalExits', Icons.logout, AppColors.accent),
        _buildStatCard('On Premises', '$onPremises', Icons.location_on, AppColors.approved),
        _buildStatCard('Expected', '$expected', Icons.schedule, AppColors.pending),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.textLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology,
              color: AppColors.textLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Insight',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Peak hours: 10-11 AM, 2-3 PM. Consider additional staff.',
                  style: TextStyle(
                    color: AppColors.textLight.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search visitors...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All', true),
              const SizedBox(width: 12),
              _buildFilterChip('Expected', false),
              const SizedBox(width: 12),
              _buildFilterChip('On Premises', false),
              const SizedBox(width: 12),
              _buildFilterChip('Total Entries', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.textLight : AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildVisitorsList(List<Visitor> visitors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Visitors',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visitors.take(5).length,
          itemBuilder: (context, index) {
            final visitor = visitors[index];
            return GestureDetector(
              onTap: () => _showVisitorDetails(context, visitor),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        visitor.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visitor.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            visitor.department,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(visitor.status),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusBadge(VisitorStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case VisitorStatus.pending:
        color = AppColors.pending;
        text = 'Expected';
        break;
      case VisitorStatus.approved:
        color = AppColors.approved;
        text = 'Approved';
        break;
      case VisitorStatus.checkedIn:
        color = AppColors.approved;
        text = 'On Premises';
        break;
      case VisitorStatus.overstay:
        color = AppColors.overstay;
        text = 'Overstay';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
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

  void _showVisitorDetails(BuildContext context, Visitor visitor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => VisitorDetailsModal(visitor: visitor),
    );
  }

  void _approveVisitor(BuildContext context, Visitor visitor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${visitor.name} approved for entry'),
        backgroundColor: AppColors.approved,
      ),
    );
  }

  void _declineVisitor(BuildContext context, Visitor visitor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${visitor.name} entry declined'),
        backgroundColor: AppColors.overstay,
      ),
    );
  }

  void _rescheduleVisitor(BuildContext context, Visitor visitor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${visitor.name} visit rescheduled'),
        backgroundColor: AppColors.pending,
      ),
    );
  }

  void _imLate(BuildContext context, Visitor visitor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notified ${visitor.name} about delay'),
        backgroundColor: AppColors.accent,
      ),
    );
  }
}