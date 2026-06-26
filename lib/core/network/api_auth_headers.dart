import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ApiAuthHeaders {
  static const _sessionKey = 'auth_session';

  static Future<Map<String, String>> withAuth(
    Map<String, String> headers,
  ) async {
    final token = await _loadToken();
    if (token.isEmpty) {
      return headers;
    }

    return {...headers, 'Authorization': 'Bearer $token'};
  }

  static Future<String> _loadToken() async {
    final preferences = await SharedPreferences.getInstance();
    final rawSession = preferences.getString(_sessionKey);
    if (rawSession == null || rawSession.isEmpty) {
      return '';
    }

    final decoded = jsonDecode(rawSession) as Map<String, dynamic>? ?? const {};
    final token = decoded['token']?.toString().trim() ?? '';
    return token;
  }
}
