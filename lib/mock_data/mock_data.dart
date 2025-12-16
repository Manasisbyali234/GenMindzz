import '../models/user.dart';
import '../models/visitor.dart';
import '../models/notification.dart';

class MockData {
  static List<Visitor> get visitors => [
    Visitor(
      id: '1',
      name: 'John Smith',
      email: 'john@example.com',
      phone: '+1234567890',
      host: 'Sarah Johnson',
      department: 'Engineering',
      purpose: 'Project Meeting',
      visitTime: DateTime.now().subtract(const Duration(hours: 1)),
      status: VisitorStatus.checkedIn,
    ),
    Visitor(
      id: '2',
      name: 'Emily Davis',
      email: 'emily@example.com',
      phone: '+1234567891',
      host: 'Mike Wilson',
      department: 'Marketing',
      purpose: 'Client Presentation',
      visitTime: DateTime.now().add(const Duration(hours: 2)),
      status: VisitorStatus.approved,
    ),
    Visitor(
      id: '3',
      name: 'Robert Brown',
      email: 'robert@example.com',
      phone: '+1234567892',
      host: 'Lisa Chen',
      department: 'Sales',
      purpose: 'Contract Discussion',
      visitTime: DateTime.now().subtract(const Duration(minutes: 30)),
      status: VisitorStatus.pending,
    ),
  ];

  static List<AppNotification> get notifications => [
    AppNotification(
      id: '1',
      title: 'Visitor Arrived',
      description: 'John Smith has arrived for the meeting',
      visitor: 'John Smith',
      host: 'Sarah Johnson',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: NotificationType.arrival,
      severity: NotificationSeverity.medium,
    ),
    AppNotification(
      id: '2',
      title: 'Approval Required',
      description: 'Emily Davis needs approval for entry',
      visitor: 'Emily Davis',
      host: 'Mike Wilson',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.approval,
      severity: NotificationSeverity.high,
    ),
  ];

  static User get securityUser => User(
    id: 'sec1',
    name: 'Security Guard',
    email: 'security@company.com',
    role: UserRole.security,
  );

  static User get employeeUser => User(
    id: 'emp1',
    name: 'John Employee',
    email: 'john@company.com',
    role: UserRole.employee,
  );
}