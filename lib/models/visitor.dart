enum VisitorStatus { pending, approved, checkedIn, overstay }

class Visitor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String host;
  final String department;
  final String purpose;
  final DateTime visitTime;
  final VisitorStatus status;
  final String? avatar;

  Visitor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.host,
    required this.department,
    required this.purpose,
    required this.visitTime,
    required this.status,
    this.avatar,
  });
}