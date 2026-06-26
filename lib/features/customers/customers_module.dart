import 'data/datasources/customers_cache_datasource.dart';
import 'data/datasources/remote/customers_remote_datasource.dart';
import 'data/repositories/customers_repository_impl.dart';
import 'domain/repositories/customers_repository.dart';

final CustomersRepository _customersRepository = CustomersRepositoryImpl(
  remoteDataSource: CustomersRemoteDataSource(),
  cacheDataSource: CustomersCacheDataSource(),
);

CustomersRepository getCustomersRepository() => _customersRepository;
