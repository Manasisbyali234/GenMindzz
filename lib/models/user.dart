enum UserRole { security, employee }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? token;
  final String? orgId;
  final String? department;
  final String? phone;
  final String? rawRole;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
    this.orgId,
    this.department,
    this.phone,
    this.rawRole,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? token,
    String? orgId,
    String? department,
    String? phone,
    String? rawRole,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
      orgId: orgId ?? this.orgId,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      rawRole: rawRole ?? this.rawRole,
    );
  }

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    final roleValue = (json['role'] ?? '').toString().toLowerCase();
    final orgMap = _asMap(json['orgId']) ?? _asMap(json['organization']);
    final idValue = _readString(json, ['_id', 'id', 'employeeId']) ?? '';

    return User(
      id: idValue,
      name: (json['name'] ?? 'User').toString(),
      email: (json['email'] ?? '').toString(),
      role: _roleFromBackend(roleValue),
      token: token ?? json['token']?.toString(),
      orgId: _readStringFromMaps(
        [json, orgMap],
        ['orgId', 'organizationId', '_id', 'id'],
      ),
      department: json['department']?.toString(),
      phone: json['phone']?.toString(),
      rawRole: roleValue.isEmpty ? null : roleValue,
    );
  }

  static UserRole _roleFromBackend(String role) {
    if (role.contains('security')) {
      return UserRole.security;
    }
    return UserRole.employee;
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
