import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/notification.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 16),
            Expanded(child: _buildContent()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildSeverityBadge(),
                const SizedBox(height: 8),
                _buildTimeAgo(),
                if (!notification.isRead) _buildUnreadDot(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;
    
    switch (notification.type) {
      case NotificationType.arrival:
        icon = Icons.person_add;
        color = AppColors.checkedIn;
        break;
      case NotificationType.approval:
        icon = Icons.approval;
        color = AppColors.pending;
        break;
      case NotificationType.alert:
        icon = Icons.warning;
        color = AppColors.overstay;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          notification.description,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.person, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              '${notification.visitor} → ${notification.host}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeverityBadge() {
    Color color;
    String text;
    
    switch (notification.severity) {
      case NotificationSeverity.low:
        color = AppColors.checkedIn;
        text = 'Low';
        break;
      case NotificationSeverity.medium:
        color = AppColors.pending;
        text = 'Medium';
        break;
      case NotificationSeverity.high:
        color = AppColors.overstay;
        text = 'High';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(notification.timestamp);
    
    String timeAgo;
    if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      timeAgo = '${difference.inHours}h ago';
    } else {
      timeAgo = '${difference.inDays}d ago';
    }

    return Text(
      timeAgo,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
      ),
    );
  }

  Widget _buildUnreadDot() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}