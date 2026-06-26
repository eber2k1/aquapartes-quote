import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiResponseReader {
  const ApiResponseReader._();

  static List<Map<String, dynamic>> readDataItems(http.Response response) {
    final data = readDataValue(response, 'leer la respuesta');
    if (data is Map<String, dynamic>) {
      return [data];
    }

    if (data is! List) {
      return const [];
    }

    return data.whereType<Map<String, dynamic>>().toList();
  }

  static List<dynamic> readDataList(http.Response response, String action) {
    final data = readDataValue(response, action);
    final items = switch (data) {
      List<dynamic> list => list,
      Map<String, dynamic> map => [map],
      _ => const <dynamic>[],
    };

    return items;
  }

  static Map<String, dynamic> readResponseData(
    http.Response response,
    String action, {
    bool flexible = false,
  }) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'No se pudo $action. Codigo: ${response.statusCode}. ${readServerMessage(response.body)}',
      );
    }

    final body = _readBody(response);
    final data = flexible ? extractResponseMap(body) : body['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta del servidor no incluye datos validos. ${readServerMessage(response.body)}',
      );
    }

    return data;
  }

  static Object? readDataValue(http.Response response, String action) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'No se pudo $action. Codigo: ${response.statusCode}. ${readServerMessage(response.body)}',
      );
    }

    final body = _readBody(response);
    return body['data'];
  }

  static String readServerMessage(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message']?.toString().trim() ?? '';
        if (message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Ignore invalid JSON while building a human-readable error.
    }

    return '';
  }

  static Map<String, dynamic>? extractResponseMap(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    const wrapperKeys = ['quote', 'result', 'item'];
    for (final key in wrapperKeys) {
      final wrappedValue = body[key];
      if (wrappedValue is Map<String, dynamic>) {
        return wrappedValue;
      }
    }

    if (body.containsKey('id') || body.containsKey('quote_number')) {
      return body;
    }

    return null;
  }

  static Map<String, dynamic> _readBody(http.Response response) {
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('La respuesta del servidor no tiene un formato valido.');
    }

    return body;
  }
}
