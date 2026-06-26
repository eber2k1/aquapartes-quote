import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response_reader.dart';
import '../../../domain/entities/system_user.dart';

class UsersRemoteDataSource {
  UsersRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<SystemUser>> fetchUsers() async {
    final response = await _apiClient.get('/api/users');
    _apiClient.validateResponse(response, 'obtener los usuarios');

    final items = ApiResponseReader.readDataList(
      response,
      'obtener los usuarios',
    );
    return items
        .whereType<Map<String, dynamic>>()
        .map(SystemUser.fromJson)
        .toList();
  }

  Future<SystemUser> fetchUserById(String id) async {
    final response = await _apiClient.get('/api/users/$id');
    _apiClient.validateResponse(response, 'obtener el usuario');

    final data = ApiResponseReader.readResponseData(
      response,
      'obtener el usuario',
    );
    return SystemUser.fromJson(data);
  }

  Future<SystemUser> createUser(SystemUser user, {String? password}) async {
    final payload = user.toJson();
    if (password != null && password.isNotEmpty) {
      payload['password'] = password;
    }

    final response = await _apiClient.post('/api/users', body: payload);
    _apiClient.validateResponse(response, 'crear el usuario');

    final data = ApiResponseReader.readResponseData(
      response,
      'crear el usuario',
    );
    return SystemUser.fromJson(data);
  }

  Future<SystemUser> updateUser(SystemUser user, {String? password}) async {
    final payload = user.toJson();
    if (password != null && password.isNotEmpty) {
      payload['password'] = password;
    }

    final response = await _apiClient.put(
      '/api/users/${user.id}',
      body: payload,
    );
    _apiClient.validateResponse(response, 'actualizar el usuario');

    final data = ApiResponseReader.readResponseData(
      response,
      'actualizar el usuario',
    );
    return SystemUser.fromJson(data);
  }

  Future<void> deleteUser(String id) async {
    final response = await _apiClient.delete('/api/users/$id');
    _apiClient.validateResponse(response, 'eliminar el usuario');
  }
}
