import '../../../../core/models/repository_load_result.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customers_repository.dart';
import '../datasources/customers_cache_datasource.dart';
import '../datasources/remote/customers_remote_datasource.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  CustomersRepositoryImpl({
    required this._remoteDataSource,
    required this._cacheDataSource,
  });

  final CustomersRemoteDataSource _remoteDataSource;
  final CustomersCacheDataSource _cacheDataSource;

  @override
  Future<RepositoryLoadResult<List<Customer>>> loadCustomers() async {
    try {
      final customers = await _remoteDataSource.fetchCustomers();
      await _cacheDataSource.saveCustomers(customers);
      return RepositoryLoadResult(data: customers, fromCache: false);
    } catch (error) {
      final cachedCustomers = await _cacheDataSource.loadCustomers();
      return RepositoryLoadResult(
        data: cachedCustomers,
        fromCache: true,
        errorMessage: error.toString(),
      );
    }
  }

  @override
  Future<void> saveCachedCustomers(List<Customer> customers) {
    return _cacheDataSource.saveCustomers(customers);
  }

  @override
  Future<Customer> createCustomer(Customer customer) {
    return _remoteDataSource.createCustomer(customer);
  }

  @override
  Future<Customer> updateCustomer(Customer customer) {
    return _remoteDataSource.updateCustomer(customer);
  }

  @override
  Future<void> deleteCustomer(String customerId) {
    return _remoteDataSource.deleteCustomer(customerId);
  }
}
