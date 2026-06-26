import 'data/datasources/profile_cache_datasource.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/repositories/profile_repository.dart';

final ProfileRepository _profileRepository = ProfileRepositoryImpl(
  cacheDataSource: ProfileCacheDataSource(),
);

ProfileRepository getProfileRepository() => _profileRepository;
