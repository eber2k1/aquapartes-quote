import 'dart:convert';

import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_auth_headers.dart';
import 'api_response_reader.dart';

class ApiClient {
  ApiClient({String? baseUrl, http.Client? client})
    : _baseUrl =
          (baseUrl ??
                  const String.fromEnvironment(
                    'API_BASE_URL',
                    defaultValue: 'https://aquaparts-quotation-tool-backend.vercel.app',
                  ))
              .trim(),
      _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  // Bandera estatica para forzar el modo offline en todas las instancias
  static bool forceOfflineMode = false;

  String get baseUrl => _baseUrl;

  void _checkOfflineMode() {
    if (forceOfflineMode) {
      throw const SocketException('Modo offline forzado activado.');
    }
  }

  Uri resolveUri(String path, [Map<String, dynamic>? queryParameters]) {
    if (_baseUrl.isEmpty) {
      throw const FormatException('Falta configurar API_BASE_URL.');
    }

    // Convert all query parameters to string for Uri.replace
    final stringQueryParameters = queryParameters?.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: stringQueryParameters);
  }

  Future<Map<String, String>> _getHeaders({
    bool requireAuth = true,
    Map<String, String>? customHeaders,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...?customHeaders,
    };

    if (requireAuth) {
      return ApiAuthHeaders.withAuth(headers);
    }
    return headers;
  }

  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requireAuth = true,
  }) async {
    _checkOfflineMode();
    final uri = resolveUri(path, queryParameters);
    final headers = await _getHeaders(requireAuth: requireAuth);
    return _client.get(uri, headers: headers);
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    bool requireAuth = true,
  }) async {
    _checkOfflineMode();
    final uri = resolveUri(path);
    final headers = await _getHeaders(requireAuth: requireAuth);
    return _client.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> put(
    String path, {
    Object? body,
    bool requireAuth = true,
  }) async {
    _checkOfflineMode();
    final uri = resolveUri(path);
    final headers = await _getHeaders(requireAuth: requireAuth);
    return _client.put(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(
    String path, {
    Object? body,
    bool requireAuth = true,
  }) async {
    _checkOfflineMode();
    final uri = resolveUri(path);
    final headers = await _getHeaders(requireAuth: requireAuth);

    // http.Client.delete no acepta un parámetro body directamente.
    // Para mandar body en un delete, hay que construir una Request manualmente.
    if (body != null) {
      final request = http.Request('DELETE', uri);
      request.headers.addAll(headers);
      request.body = jsonEncode(body);
      final streamedResponse = await _client.send(request);
      return http.Response.fromStream(streamedResponse);
    }

    return _client.delete(uri, headers: headers);
  }

  Future<http.Response> sendMultipart(
    http.MultipartRequest request, {
    bool requireAuth = true,
  }) async {
    _checkOfflineMode();
    final headers = await _getHeaders(requireAuth: requireAuth);
    headers.remove(
      'Content-Type',
    ); // Importante: MultipartRequest genera su propio Content-Type con boundary
    request.headers.addAll(headers);
    final streamedResponse = await _client.send(request);
    return http.Response.fromStream(streamedResponse);
  }

  void validateResponse(http.Response response, String action) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'No se pudo $action. Codigo: ${response.statusCode}. ${ApiResponseReader.readServerMessage(response.body)}',
      );
    }
  }
}
