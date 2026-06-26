import '../../domain/entities/auth_code_request_result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_cache_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/profile_module.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._remoteDataSource,
    required this._cacheDataSource,
  });

  final AuthRemoteDataSource _remoteDataSource;
  final AuthCacheDataSource _cacheDataSource;

  @override
  Future<AuthSession?> loadSession() {
    return _cacheDataSource.loadSession();
  }

  @override
  Future<AuthCodeRequestResult> requestCode(String email) {
    return _remoteDataSource.requestCode(email.trim());
  }

  @override
  Future<AuthSession> verifyCode({
    required String email,
    required String code,
  }) async {
    final session = await _remoteDataSource.verifyCode(
      email: email.trim(),
      code: code.trim(),
    );
    await _cacheDataSource.saveSession(session);

    // También guardar el perfil del usuario desde la sesión
    final profile = UserProfile(
      paternalLastName: session.user.lastNamePaternal,
      maternalLastName: session.user.lastNameMaternal,
      firstNames: session.user.firstName,
      phone: session.user.phone,
      position: session.user.position,
      email: session.user.email,
    );
    await getProfileRepository().saveProfile(profile);

    return session;
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _cacheDataSource.clearSession();
    // También limpiamos el perfil del usuario
    await getProfileRepository().saveProfile(
      const UserProfile(
        paternalLastName: '',
        maternalLastName: '',
        firstNames: '',
        phone: '',
        position: '',
        email: '',
      ),
    );
  }

  @override
  Future<void> clearSession() {
    return _cacheDataSource.clearSession();
  }
}
