import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../visitors/visitors_provider.dart';
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
    Future.microtask(() {
      ref.read(visitorsStateProvider.notifier).loadVisitors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visitorsState = ref.watch(visitorsStateProvider);
    final notifications = ref.watch(filteredNotificationsProvider);

    if (visitorsState.isLoading && !visitorsState.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.textLight,
          unselectedLabelColor: AppColors.textLight.withOpacity(0.7),
          indicatorColor: AppColors.textLight,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Arrivals'),
            Tab(text: 'Approvals'),
            Tab(text: 'Alerts'),
          ],
          onTap: (index) => _onTabChanged(index),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildNotificationsList(notifications),
            _buildNotificationsList(notifications),
            _buildNotificationsList(notifications),
            _buildNotificationsList(notifications),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    final visitorsState = ref.watch(visitorsStateProvider);

    if (visitorsState.error != null && notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.overstay),
              const SizedBox(height: 12),
              Text(
                visitorsState.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.black54),
            SizedBox(height: 16),
            Text('No notifications', style: TextStyle(color: Colors.black54)),
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
