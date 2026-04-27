import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/notification.dart';
import '../../models/user.dart';
import '../../models/visitor.dart';
import '../auth/auth_provider.dart';
import '../visitors/visitors_provider.dart';

final notificationsProvider = Provider<List<AppNotification>>((ref) {
  final user = ref.watch(authProvider).user;
  final visitors = ref.watch(visitorsProvider);

  if (user == null) {
    return const [];
  }

  final scopedVisitors = _scopeVisitorsForUser(visitors, user);
  final notifications = scopedVisitors
      .map(_notificationFromVisitor)
      .toList()
    ..sort((first, second) => second.timestamp.compareTo(first.timestamp));

  return notifications;
});

final selectedNotificationTypeProvider = StateProvider<NotificationType?>(
  (ref) => null,
);

final filteredNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final notifications = ref.watch(notificationsProvider);
  final filter = ref.watch(selectedNotificationTypeProvider);

  if (filter == null) {
    return notifications;
  }

  return notifications
      .where((notification) => notification.type == filter)
      .toList();
});

List<Visitor> _scopeVisitorsForUser(List<Visitor> visitors, User user) {
  if (user.role == UserRole.security) {
    return visitors;
  }

  final normalizedUserId = user.id.trim().toLowerCase();
  final normalizedUserName = user.name.trim().toLowerCase();
  final ownedVisitors = visitors.where((visitor) {
    final hostId = visitor.hostId?.trim().toLowerCase();
    if (normalizedUserId.isNotEmpty && hostId != null && hostId.isNotEmpty) {
      return hostId == normalizedUserId;
    }

    return visitor.host.trim().toLowerCase() == normalizedUserName;
  }).toList();

  return ownedVisitors.isNotEmpty ? ownedVisitors : visitors;
}

AppNotification _notificationFromVisitor(Visitor visitor) {
  final status = visitor.status;
  return AppNotification(
    id: visitor.id.isEmpty
        ? '${visitor.name}-${visitor.visitTime.toIso8601String()}'
        : visitor.id,
    title: _notificationTitle(visitor),
    description: _notificationDescription(visitor),
    visitor: visitor.name,
    host: visitor.host,
    timestamp: visitor.visitTime,
    type: _notificationType(status),
    severity: _notificationSeverity(status),
    isRead: visitor.visitTime.isBefore(
      DateTime.now().subtract(const Duration(hours: 12)),
    ),
  );
}

NotificationType _notificationType(VisitorStatus status) {
  switch (status) {
    case VisitorStatus.checkedIn:
    case VisitorStatus.checkedOut:
      return NotificationType.arrival;
    case VisitorStatus.pending:
    case VisitorStatus.approved:
    case VisitorStatus.invited:
      return NotificationType.approval;
    case VisitorStatus.blocked:
    case VisitorStatus.overstay:
      return NotificationType.alert;
  }
}

NotificationSeverity _notificationSeverity(VisitorStatus status) {
  switch (status) {
    case VisitorStatus.blocked:
    case VisitorStatus.overstay:
      return NotificationSeverity.high;
    case VisitorStatus.pending:
    case VisitorStatus.approved:
      return NotificationSeverity.medium;
    case VisitorStatus.invited:
    case VisitorStatus.checkedIn:
    case VisitorStatus.checkedOut:
      return NotificationSeverity.low;
  }
}

String _notificationTitle(Visitor visitor) {
  switch (visitor.status) {
    case VisitorStatus.pending:
      return 'Approval needed for ${visitor.name}';
    case VisitorStatus.approved:
      return '${visitor.name} has been approved';
    case VisitorStatus.checkedIn:
      return '${visitor.name} checked in';
    case VisitorStatus.overstay:
      return '${visitor.name} has overstayed';
    case VisitorStatus.invited:
      return 'Invitation created for ${visitor.name}';
    case VisitorStatus.checkedOut:
      return '${visitor.name} checked out';
    case VisitorStatus.blocked:
      return '${visitor.name} was blocked';
  }
}

String _notificationDescription(Visitor visitor) {
  final schedule = _formatSchedule(visitor.visitTime);
  switch (visitor.status) {
    case VisitorStatus.pending:
      return '${visitor.purpose} request scheduled for $schedule.';
    case VisitorStatus.approved:
      return 'Approved visit for $schedule.';
    case VisitorStatus.checkedIn:
      return '${visitor.name} arrived for ${visitor.purpose.toLowerCase()}.';
    case VisitorStatus.overstay:
      return '${visitor.name} needs attention due to an extended visit.';
    case VisitorStatus.invited:
      return 'Invite shared for $schedule.';
    case VisitorStatus.checkedOut:
      return '${visitor.name} has completed the visit.';
    case VisitorStatus.blocked:
      return visitor.rejectReason?.trim().isNotEmpty == true
          ? visitor.rejectReason!.trim()
          : 'The visit was rejected before arrival.';
  }
}

String _formatSchedule(DateTime visitTime) {
  final hour = visitTime.hour % 12 == 0 ? 12 : visitTime.hour % 12;
  final minute = visitTime.minute.toString().padLeft(2, '0');
  final period = visitTime.hour >= 12 ? 'PM' : 'AM';
  final day = visitTime.day.toString().padLeft(2, '0');
  final month = visitTime.month.toString().padLeft(2, '0');

  return '$day/$month/${visitTime.year} at $hour:$minute $period';
}
