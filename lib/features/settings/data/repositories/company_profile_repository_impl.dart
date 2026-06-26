import '../../domain/entities/company_profile.dart';
import '../../domain/repositories/company_profile_repository.dart';
import '../datasources/company_profile_cache_datasource.dart';

class CompanyProfileRepositoryImpl implements CompanyProfileRepository {
  CompanyProfileRepositoryImpl({required this._cacheDataSource});

  final CompanyProfileCacheDataSource _cacheDataSource;

  @override
  Future<CompanyProfile?> loadProfile() {
    return _cacheDataSource.loadProfile();
  }

  @override
  Future<void> saveProfile(CompanyProfile profile) {
    return _cacheDataSource.saveProfile(profile);
  }
}
