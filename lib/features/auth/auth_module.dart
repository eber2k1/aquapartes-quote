import 'data/datasources/auth_cache_datasource.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';

final AuthRepository _authRepository = AuthRepositoryImpl(
  remoteDataSource: AuthRemoteDataSource(),
  cacheDataSource: AuthCacheDataSource(),
);

AuthRepository getAuthRepository() => _authRepository;
