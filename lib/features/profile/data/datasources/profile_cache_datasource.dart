import 'dart:convert';

import '../../../../../core/storage/cache_client.dart';
import '../../domain/entities/user_profile.dart';

class ProfileCacheDataSource {
  static const _profileKey = 'user_profile';
  final CacheClient _cache = const CacheClient();

  Future<UserProfile?> loadProfile() async {
    final rawProfile = await _cache.getString(_profileKey);

    if (rawProfile == null || rawProfile.isEmpty) {
      return null;
    }

    return UserProfile.fromJson(jsonDecode(rawProfile) as Map<String, dynamic>);
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _cache.setString(_profileKey, jsonEncode(profile.toJson()));
  }
}
