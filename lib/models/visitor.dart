enum VisitorStatus {
  pending,
  approved,
  checkedIn,
  overstay,
  invited,
  checkedOut,
  blocked,
}

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
  final String? hostId;
  final String? timeFrom;
  final String? timeTo;
  final String? registrationSource;
  final String? rejectReason;
  final String? inviteToken;

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
    this.hostId,
    this.timeFrom,
    this.timeTo,
    this.registrationSource,
    this.rejectReason,
    this.inviteToken,
  });

  Visitor copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? host,
    String? department,
    String? purpose,
    DateTime? visitTime,
    VisitorStatus? status,
    String? avatar,
    String? hostId,
    String? timeFrom,
    String? timeTo,
    String? registrationSource,
    String? rejectReason,
    String? inviteToken,
  }) {
    return Visitor(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      host: host ?? this.host,
      department: department ?? this.department,
      purpose: purpose ?? this.purpose,
      visitTime: visitTime ?? this.visitTime,
      status: status ?? this.status,
      avatar: avatar ?? this.avatar,
      hostId: hostId ?? this.hostId,
      timeFrom: timeFrom ?? this.timeFrom,
      timeTo: timeTo ?? this.timeTo,
      registrationSource: registrationSource ?? this.registrationSource,
      rejectReason: rejectReason ?? this.rejectReason,
      inviteToken: inviteToken ?? this.inviteToken,
    );
  }

  factory Visitor.fromJson(Map<String, dynamic> json) {
    final hostMap = _asMap(json['host']);
    final name = _readString(json, ['visitorName', 'name']);
    final hostName = _readStringFromMaps(
      [json, hostMap],
      ['hostName', 'name', 'host'],
    );
    final visitingDate = _readString(json, ['visitingDate', 'date']);
    final timeFrom = _readString(json, ['timeFrom', 'startTime']);

    return Visitor(
      id: _readString(json, ['_id', 'id']) ?? '',
      name: name ?? 'Unknown Visitor',
      email: _readString(json, ['email']) ?? '',
      phone: _readString(json, ['phone']) ?? '',
      host: hostName ?? 'Unassigned',
      department:
          _readStringFromMaps([json, hostMap], ['department', 'hostDepartment']) ??
          'General',
      purpose: _readString(json, ['purpose', 'description']) ?? 'Visit',
      visitTime: _parseVisitTime(json, visitingDate, timeFrom),
      status: visitorStatusFromApi(_readString(json, ['status'])),
      avatar: _readString(json, ['avatar', 'image', 'imageUrl']),
      hostId: _readStringFromMaps([json, hostMap], ['hostId', '_id', 'id']),
      timeFrom: timeFrom,
      timeTo: _readString(json, ['timeTo', 'endTime']),
      registrationSource: _readString(json, ['registrationSource']),
      rejectReason: _readString(json, ['rejectReason']),
      inviteToken: _readString(json, ['token', 'inviteToken']),
    );
  }
}

extension VisitorStatusApi on VisitorStatus {
  String get apiValue {
    switch (this) {
      case VisitorStatus.pending:
        return 'pending';
      case VisitorStatus.approved:
        return 'approved';
      case VisitorStatus.checkedIn:
        return 'checked_in';
      case VisitorStatus.overstay:
        return 'overstay';
      case VisitorStatus.invited:
        return 'invited';
      case VisitorStatus.checkedOut:
        return 'checked_out';
      case VisitorStatus.blocked:
        return 'blocked';
    }
  }

  String get label {
    switch (this) {
      case VisitorStatus.pending:
        return 'Pending';
      case VisitorStatus.approved:
        return 'Approved';
      case VisitorStatus.checkedIn:
        return 'Checked In';
      case VisitorStatus.overstay:
        return 'Overstay';
      case VisitorStatus.invited:
        return 'Invited';
      case VisitorStatus.checkedOut:
        return 'Checked Out';
      case VisitorStatus.blocked:
        return 'Blocked';
    }
  }
}

VisitorStatus visitorStatusFromApi(String? value) {
  switch ((value ?? '').toLowerCase()) {
    case 'approved':
      return VisitorStatus.approved;
    case 'checked_in':
    case 'checkedin':
      return VisitorStatus.checkedIn;
    case 'checked_out':
    case 'checkedout':
      return VisitorStatus.checkedOut;
    case 'invited':
      return VisitorStatus.invited;
    case 'blocked':
    case 'rejected':
      return VisitorStatus.blocked;
    case 'overstay':
      return VisitorStatus.overstay;
    case 'pending':
    default:
      return VisitorStatus.pending;
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, entry) => MapEntry(key.toString(), entry));
  }
  return null;
}

String? _readString(Map<String, dynamic>? source, List<String> keys) {
  if (source == null) {
    return null;
  }

  for (final key in keys) {
    final value = source[key];
    if (value == null) {
      continue;
    }

    final text = value.toString().trim();
    if (text.isNotEmpty) {
      return text;
    }
  }

  return null;
}

String? _readStringFromMaps(
  List<Map<String, dynamic>?> maps,
  List<String> keys,
) {
  for (final map in maps) {
    final value = _readString(map, keys);
    if (value != null) {
      return value;
    }
  }
  return null;
}

DateTime _parseVisitTime(
  Map<String, dynamic> json,
  String? visitingDate,
  String? timeFrom,
) {
  final directDate = _readString(json, ['visitTime', 'createdAt', 'updatedAt']);
  if (directDate != null) {
    final parsed = DateTime.tryParse(directDate);
    if (parsed != null) {
      return parsed.toLocal();
    }
  }

  if (visitingDate != null) {
    final date = DateTime.tryParse(visitingDate);
    if (date != null) {
      if (timeFrom == null) {
        return date;
      }

      final parts = timeFrom.split(':');
      final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      return DateTime(date.year, date.month, date.day, hour, minute);
    }
  }

  return DateTime.now();
}
