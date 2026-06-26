import '../entities/auth_code_request_result.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession?> loadSession();
  Future<AuthCodeRequestResult> requestCode(String email);
  Future<AuthSession> verifyCode({required String email, required String code});
  Future<void> logout();
  Future<void> clearSession();
}
