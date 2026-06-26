import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response_reader.dart';
import '../../../domain/entities/customer.dart';
import '../../models/customer_remote_model.dart';

class CustomersRemoteDataSource {
  CustomersRemoteDataSource({ApiClient? apiClient})
    : _apiUserId = const String.fromEnvironment('API_USER_ID'),
      _apiClient = apiClient ?? ApiClient();

  final String _apiUserId;
  final ApiClient _apiClient;

  Future<List<Customer>> fetchCustomers({String? searchQuery}) async {
    final queryParams = <String, dynamic>{};
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['q'] = searchQuery;
    }

    final response = await _apiClient.get(
      '/api/customers',
      queryParameters: queryParams,
    );

    _apiClient.validateResponse(response, 'cargar los clientes');

    final items = ApiResponseReader.readDataItems(response);

    return items
        .whereType<Map<String, dynamic>>()
        .map(CustomerRemoteModel.fromJson)
        .where((customer) => customer.deletedAt == null)
        .map((model) => model.toEntity())
        .toList();
  }

  Future<Customer> fetchCustomerById(String customerId) async {
    final response = await _apiClient.get('/api/customers/$customerId');
    _apiClient.validateResponse(response, 'obtener el cliente');

    return CustomerRemoteModel.fromJson(
      _readResponseData(response, 'obtener el cliente'),
    ).toEntity();
  }

  Future<Customer> createCustomer(Customer customer) async {
    final createdBy = customer.createdBy.trim().isNotEmpty
        ? customer.createdBy.trim()
        : _apiUserId.trim();
    if (createdBy.isEmpty) {
      throw Exception(
        'Falta configurar API_USER_ID para crear clientes en el backend.',
      );
    }

    final remoteModel = CustomerRemoteModel(
      id: customer.id ?? '',
      companyName: customer.companyName,
      contactName: customer.contactName,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      createdBy: createdBy,
      createdByUserName: customer.createdByUserName,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
      deletedAt: customer.deletedAt,
    );

    final response = await _apiClient.post(
      '/api/customers',
      body: remoteModel.toCreatePayload(createdBy: createdBy),
    );

    _apiClient.validateResponse(response, 'crear el cliente');

    return CustomerRemoteModel.fromJson(
      _readResponseData(response, 'crear el cliente'),
    ).toEntity();
  }

  Future<Customer> updateCustomer(Customer customer) async {
    final customerId = customer.id?.trim() ?? '';
    if (customerId.isEmpty) {
      throw Exception('No se puede actualizar un cliente sin id remoto.');
    }

    final remoteModel = CustomerRemoteModel(
      id: customerId,
      companyName: customer.companyName,
      contactName: customer.contactName,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      createdBy: customer.createdBy,
      createdByUserName: customer.createdByUserName,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
      deletedAt: customer.deletedAt,
    );

    final response = await _apiClient.put(
      '/api/customers/$customerId',
      body: remoteModel.toUpdatePayload(),
    );

    _apiClient.validateResponse(response, 'actualizar el cliente');

    return CustomerRemoteModel.fromJson(
      _readResponseData(response, 'actualizar el cliente'),
    ).toEntity();
  }

  Future<void> deleteCustomer(String customerId) async {
    final response = await _apiClient.delete('/api/customers/$customerId');
    _apiClient.validateResponse(response, 'eliminar el cliente');
  }

  Map<String, dynamic> _readResponseData(dynamic response, String action) =>
      ApiResponseReader.readResponseData(response, action);
}
