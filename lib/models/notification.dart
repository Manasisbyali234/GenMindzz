enum NotificationType { arrival, approval, alert }
enum NotificationSeverity { low, medium, high }

class AppNotification {
  final String id;
  final String title;
  final String description;
  final String visitor;
  final String host;
  final DateTime timestamp;
  final NotificationType type;
  final NotificationSeverity severity;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.visitor,
    required this.host,
    required this.timestamp,
    required this.type,
    required this.severity,
    this.isRead = false,
  });
}