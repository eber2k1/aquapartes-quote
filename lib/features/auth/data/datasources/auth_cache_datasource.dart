import 'dart:convert';

import '../../../../../core/storage/cache_client.dart';
import '../../domain/entities/auth_session.dart';

class AuthCacheDataSource {
  static const _sessionKey = 'auth_session';
  final CacheClient _cache = const CacheClient();

  Future<AuthSession?> loadSession() async {
    final rawSession = await _cache.getString(_sessionKey);

    if (rawSession == null || rawSession.isEmpty) {
      return null;
    }

    return AuthSession.fromJson(
      jsonDecode(rawSession) as Map<String, dynamic>? ?? const {},
    );
  }

  Future<void> saveSession(AuthSession session) async {
    await _cache.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<void> clearSession() async {
    await _cache.remove(_sessionKey);
  }
}
