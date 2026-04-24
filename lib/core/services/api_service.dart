import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/user.dart';
import '../../models/visitor.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class LoginResult {
  final String token;
  final User user;

  LoginResult({
    required this.token,
    required this.user,
  });
}

class ScanResult {
  final bool success;
  final String? type;
  final String? action;
  final Map<String, dynamic>? record;

  ScanResult({
    required this.success,
    this.type,
    this.action,
    this.record,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      success: json['success'] == true,
      type: json['type']?.toString(),
      action: json['action']?.toString(),
      record: _asMap(json['record']),
    );
  }
}

class ApiService {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.genmindz.in',
  );
  static const String _webProxyBaseUrl = String.fromEnvironment(
    'WEB_DEV_PROXY_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    final source = _configuredBaseUrl.trim().isNotEmpty
        ? _configuredBaseUrl.trim()
        : _webProxyBaseUrl.trim().isNotEmpty
            ? _webProxyBaseUrl.trim()
            : 'https://api.genmindz.in';
    final trimmed = source.endsWith('/')
        ? source.substring(0, source.length - 1)
        : source;
    return trimmed.endsWith('/api') ? trimmed : '$trimmed/api';
  }

  static Future<LoginResult> login({
    required String email,
    required String password,
    required String captchaToken,
  }) async {
    final data = await _requestJson(
      method: 'POST',
      path: '/auth/login',
      body: {
        'email': email,
        'password': password,
        'captchaToken': captchaToken,
      },
    );

    final map = _requireMap(data);
    final token = map['token']?.toString();
    final userJson = _asMap(map['user']);

    if (token == null || token.isEmpty || userJson == null) {
      throw ApiException('Login response did not include token and user data.');
    }

    return LoginResult(
      token: token,
      user: User.fromJson(userJson, token: token),
    );
  }

  static Future<User> getCurrentUser(String token) async {
    final data = await _requestJson(
      method: 'GET',
      path: '/users/me',
      token: token,
    );

    return User.fromJson(_unwrapObject(data), token: token);
  }

  static Future<Map<String, dynamic>> updateOwnProfile({
    required String token,
    required Map<String, dynamic> fields,
  }) async {
    final data = await _requestMultipart(
      method: 'PUT',
      path: '/users/me',
      token: token,
      fields: fields,
    );

    return _unwrapObject(data);
  }

  static Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final data = await _requestJson(
      method: 'PUT',
      path: '/users/me/password',
      token: token,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );

    return _unwrapObject(data);
  }

  static Future<List<Visitor>> getVisits(
    String token, {
    int page = 1,
    int limit = 100,
  }) async {
    final data = await _requestJson(
      method: 'GET',
      path: '/visits',
      token: token,
      query: {
        'page': page,
        'limit': limit,
      },
    );

    return _unwrapList(data).map(Visitor.fromJson).toList();
  }

  static Future<Visitor> createVisit({
    String? token,
    required Map<String, dynamic> fields,
  }) async {
    final data = await _requestMultipart(
      method: 'POST',
      path: '/visits',
      token: token,
      fields: fields,
    );

    return Visitor.fromJson(_unwrapObject(data));
  }

  static Future<Visitor> updateVisit({
    required String token,
    required String visitId,
    required Map<String, dynamic> fields,
  }) async {
    final data = await _requestJson(
      method: 'PUT',
      path: '/visits/$visitId',
      token: token,
      body: fields,
    );

    return Visitor.fromJson(_unwrapObject(data));
  }

  static Future<String> issueInvite({
    required String token,
    required String visitId,
    required String orgId,
  }) async {
    final data = await _requestJson(
      method: 'POST',
      path: '/invites',
      token: token,
      body: {
        'visitId': visitId,
        'orgId': orgId,
      },
    );

    final map = _unwrapObject(data);
    final inviteToken = map['token']?.toString();
    if (inviteToken == null || inviteToken.isEmpty) {
      throw ApiException('Invite response did not include a token.');
    }

    return inviteToken;
  }

  static Future<ScanResult> scanQr({
    required String token,
    required String qrCode,
    required String performer,
  }) async {
    final data = await _requestJson(
      method: 'POST',
      path: '/scan',
      token: token,
      body: {
        'qrCode': qrCode,
        'performer': performer,
      },
    );

    return ScanResult.fromJson(_unwrapObject(data));
  }

  static Future<Visitor> confirmScan({
    required String token,
    required String visitId,
    required String status,
    required String performer,
    String? note,
    String? batchId,
  }) async {
    final data = await _requestJson(
      method: 'POST',
      path: '/scan/confirm',
      token: token,
      body: {
        'visitId': visitId,
        'status': status,
        'performer': performer,
        'note': note,
        'batchId': batchId,
      },
    );

    final map = _unwrapObject(data);
    final visit = _asMap(map['visit']) ?? map;
    return Visitor.fromJson(visit);
  }

  static Future<List<Map<String, dynamic>>> getTasks({
    required String token,
    required String orgId,
  }) async {
    final data = await _requestJson(
      method: 'GET',
      path: '/tasks',
      token: token,
      query: {'orgId': orgId},
    );

    return _unwrapList(data);
  }

  static Future<Map<String, dynamic>> createTask({
    required String token,
    required Map<String, dynamic> fields,
  }) async {
    final data = await _requestJson(
      method: 'POST',
      path: '/tasks',
      token: token,
      body: fields,
    );

    return _unwrapObject(data);
  }

  static Future<List<Map<String, dynamic>>> listUsers({
    required String token,
    required String orgId,
    String? category,
    String? search,
    int? page,
    int? limit,
  }) async {
    final data = await _requestJson(
      method: 'GET',
      path: '/users/$orgId',
      token: token,
      query: {
        'category': category,
        'search': search,
        'page': page,
        'limit': limit,
      },
    );

    return _unwrapList(data);
  }

  static Future<dynamic> _requestJson({
    required String method,
    required String path,
    String? token,
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    final request = http.Request(method, _buildUri(path, query));
    request.headers.addAll(_buildHeaders(token: token, jsonBody: true));

    if (body != null) {
      request.body = jsonEncode(_cleanMap(body));
    }

    final response = await request.send();
    return _decodeResponse(response);
  }

  static Future<dynamic> _requestMultipart({
    required String method,
    required String path,
    String? token,
    Map<String, dynamic>? fields,
    Map<String, dynamic>? query,
  }) async {
    final request = http.MultipartRequest(method, _buildUri(path, query));
    request.headers.addAll(_buildHeaders(token: token, jsonBody: false));

    for (final entry in _cleanMap(fields ?? {}).entries) {
      final value = entry.value;
      if (value is List || value is Map) {
        request.fields[entry.key] = jsonEncode(value);
      } else {
        request.fields[entry.key] = value.toString();
      }
    }

    final response = await request.send();
    return _decodeResponse(response);
  }

  static Future<dynamic> _decodeResponse(http.StreamedResponse response) async {
    final body = await response.stream.bytesToString();
    dynamic decoded;

    if (body.isNotEmpty) {
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        decoded = body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded ?? <String, dynamic>{};
    }

    throw ApiException(
      _extractMessage(decoded) ?? 'Request failed with status ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  static Uri _buildUri(String path, Map<String, dynamic>? query) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$normalizedPath');
    final queryParameters = <String, String>{};

    if (query != null) {
      for (final entry in query.entries) {
        if (entry.value == null) {
          continue;
        }

        final value = entry.value.toString();
        if (value.isEmpty) {
          continue;
        }

        queryParameters[entry.key] = value;
      }
    }

    return queryParameters.isEmpty
        ? uri
        : uri.replace(queryParameters: queryParameters);
  }

  static Map<String, String> _buildHeaders({
    String? token,
    required bool jsonBody,
  }) {
    return {
      if (jsonBody) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _cleanMap(Map<String, dynamic> input) {
    final result = <String, dynamic>{};

    for (final entry in input.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }

      if (value is String && value.trim().isEmpty) {
        continue;
      }

      result[entry.key] = value;
    }

    return result;
  }
}

Map<String, dynamic> _unwrapObject(dynamic data) {
  if (data is Map<String, dynamic>) {
    final nestedData = data['data'];
    if (nestedData is Map<String, dynamic>) {
      return nestedData;
    }
    return data;
  }

  if (data is Map) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }

  throw ApiException('Expected an object response from the server.');
}

List<Map<String, dynamic>> _unwrapList(dynamic data) {
  final source = data is Map<String, dynamic> && data['data'] is List
      ? data['data'] as List<dynamic>
      : data is List
          ? data
          : <dynamic>[];

  return source.map(_requireMap).toList();
}

Map<String, dynamic> _requireMap(dynamic value) {
  final map = _asMap(value);
  if (map == null) {
    throw ApiException('Expected a valid JSON object from the server.');
  }
  return map;
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

String? _extractMessage(dynamic body) {
  if (body is String && body.trim().isNotEmpty) {
    return body.trim();
  }

  final map = _asMap(body);
  if (map == null) {
    return null;
  }

  final candidates = ['message', 'error', 'detail'];
  for (final key in candidates) {
    final value = map[key];
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
