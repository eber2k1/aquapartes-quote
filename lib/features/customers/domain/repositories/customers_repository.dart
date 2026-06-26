import '../../../../core/models/repository_load_result.dart';
import '../entities/customer.dart';

abstract class CustomersRepository {
  Future<RepositoryLoadResult<List<Customer>>> loadCustomers();
  Future<void> saveCachedCustomers(List<Customer> customers);
  Future<Customer> createCustomer(Customer customer);
  Future<Customer> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String customerId);
}
