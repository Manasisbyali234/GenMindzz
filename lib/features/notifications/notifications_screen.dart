import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notification.dart';
import 'notifications_provider.dart';
import 'widgets/notification_card.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(filteredNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Arrivals'),
            Tab(text: 'Approvals'),
            Tab(text: 'Alerts'),
          ],
          onTap: (index) => _onTabChanged(index),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(notifications),
          _buildNotificationsList(notifications),
          _buildNotificationsList(notifications),
          _buildNotificationsList(notifications),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('No notifications', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) => NotificationCard(
        notification: notifications[index],
      ),
    );
  }

  void _onTabChanged(int index) {
    NotificationType? filter;
    switch (index) {
      case 0:
        filter = null;
        break;
      case 1:
        filter = NotificationType.arrival;
        break;
      case 2:
        filter = NotificationType.approval;
        break;
      case 3:
        filter = NotificationType.alert;
        break;
    }
    ref.read(selectedNotificationTypeProvider.notifier).state = filter;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}