import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response_reader.dart';
import '../../../domain/entities/auth_code_request_result.dart';
import '../../../domain/entities/auth_session.dart';
import '../../models/auth_user_remote_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AuthCodeRequestResult> requestCode(String email) async {
    final response = await _apiClient.post(
      '/api/auth/request-code',
      body: {'email': email},
      requireAuth: false,
    );

    if (response.statusCode == 404 || response.statusCode == 400) {
       final serverMsg = ApiResponseReader.readServerMessage(response.body);
       throw Exception(serverMsg.isNotEmpty ? serverMsg : 'El correo ingresado no está registrado o no es exacto. Por favor, verifícalo.');
    }

    _apiClient.validateResponse(response, 'solicitar codigo de verificacion');

    final json = _decodeJson(response);
    final data = ApiResponseReader.extractResponseMap(json) ?? json;
    return AuthCodeRequestResult(
      message:
          _readString(json['message']) ?? 'Codigo de verificacion enviado.',
      debugCode: _readString(data['debug_code']),
      mailDelivery: _readString(data['mail_delivery']),
    );
  }

  Future<AuthSession> verifyCode({
    required String email,
    required String code,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/verify-code',
      body: {'email': email, 'code': code},
      requireAuth: false,
    );

    _apiClient.validateResponse(response, 'verificar codigo');

    final json = _decodeJson(response);
    final data = ApiResponseReader.extractResponseMap(json);
    if (data == null) {
      throw const FormatException(
        'La respuesta de autenticacion no contiene el objeto "data".',
      );
    }

    final token = _readString(data['token']);
    final userJson = data['user'] as Map<String, dynamic>? ?? const {};
    final user = AuthUserRemoteModel.fromJson(userJson).toEntity();

    if ((token ?? '').isEmpty || user.id.trim().isEmpty) {
      throw const FormatException(
        'La respuesta de autenticacion no contiene token o user.id validos.',
      );
    }

    return AuthSession(token: token!, user: user);
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    if (response.body.trim().isEmpty) {
      return const {};
    }

    final decoded = jsonDecode(response.body);
    return decoded as Map<String, dynamic>? ?? const {};
  }

  String? _readString(Object? value) {
    final result = value?.toString().trim();
    return (result == null || result.isEmpty) ? null : result;
  }

  Future<void> logout() async {
    final response = await _apiClient.post('/api/auth/logout');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Incluso si falla, limpiamos la sesión localmente
      return;
    }
  }
}
