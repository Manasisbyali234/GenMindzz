import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/notification.dart';
import '../../mock_data/mock_data.dart';

final notificationsProvider = StateProvider<List<AppNotification>>((ref) {
  return MockData.notifications;
});

final selectedNotificationTypeProvider = StateProvider<NotificationType?>((ref) => null);

final filteredNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final notifications = ref.watch(notificationsProvider);
  final filter = ref.watch(selectedNotificationTypeProvider);
  
  if (filter == null) return notifications;
  return notifications.where((notification) => notification.type == filter).toList();
});