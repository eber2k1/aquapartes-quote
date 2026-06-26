import 'dart:convert';

import '../../../../../core/storage/cache_client.dart';
import '../../domain/entities/company_profile.dart';

class CompanyProfileCacheDataSource {
  static const _profileKey = 'company_profile';
  final CacheClient _cache = const CacheClient();

  Future<CompanyProfile?> loadProfile() async {
    final rawProfile = await _cache.getString(_profileKey);

    if (rawProfile == null || rawProfile.isEmpty) {
      return null;
    }

    return CompanyProfile.fromJson(
      jsonDecode(rawProfile) as Map<String, dynamic>,
    );
  }

  Future<void> saveProfile(CompanyProfile profile) async {
    await _cache.setString(_profileKey, jsonEncode(profile.toJson()));
  }
}
