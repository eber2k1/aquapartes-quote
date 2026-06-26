import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_cache_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required this._cacheDataSource});

  final ProfileCacheDataSource _cacheDataSource;

  @override
  Future<UserProfile?> loadProfile() {
    return _cacheDataSource.loadProfile();
  }

  @override
  Future<void> saveProfile(UserProfile profile) {
    return _cacheDataSource.saveProfile(profile);
  }
}
