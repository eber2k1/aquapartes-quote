import '../../../../core/services/app_notifications.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customers_repository.dart';
import '../models/customer_form_result.dart';

class CustomerActionCoordinator {
  CustomerActionCoordinator({required this.repository});

  final CustomersRepository repository;

  Future<List<Customer>> loadCustomers() async {
    final result = await repository.loadCustomers();

    if (result.fromCache) {
      AppNotifications.showInfo(
        'No se pudo cargar la lista de clientes desde la API. Se mostraran los datos locales.',
      );
    }

    return result.data;
  }

  Future<List<Customer>> applyResult({
    required List<Customer> currentCustomers,
    required CustomerFormResult result,
    Customer? initialCustomer,
    int? index,
  }) async {
    final customers = List<Customer>.from(currentCustomers);
    final deletedCustomerLabel = initialCustomer == null
        ? null
        : buildCustomerLabel(initialCustomer);

    Customer? savedCustomer;

    if (result.deleted) {
      if (index == null || index < 0 || index >= customers.length) {
        return customers;
      }

      final customerId = initialCustomer?.id?.trim() ?? '';
      if (customerId.isNotEmpty) {
        await repository.deleteCustomer(customerId);
      }

      customers.removeAt(index);
    } else if (result.customer != null) {
      final customerToPersist = result.customer!.copyWith(
        id: initialCustomer?.id,
        createdBy: initialCustomer?.createdBy ?? result.customer!.createdBy,
        createdAt: initialCustomer?.createdAt ?? result.customer!.createdAt,
      );

      savedCustomer = index == null
          ? await repository.createCustomer(customerToPersist)
          : await repository.updateCustomer(customerToPersist);

      if (index == null) {
        customers.add(savedCustomer);
      } else if (index >= 0 && index < customers.length) {
        customers[index] = savedCustomer;
      }
    }

    await repository.saveCachedCustomers(customers);

    if (result.deleted && deletedCustomerLabel != null) {
      AppNotifications.showDelete(
        'Cliente "$deletedCustomerLabel" eliminado correctamente.',
      );
      return customers;
    }

    if (savedCustomer != null) {
      AppNotifications.showSuccess(
        index == null
            ? 'Cliente "${buildCustomerLabel(savedCustomer)}" creado correctamente.'
            : 'Cliente "${buildCustomerLabel(savedCustomer)}" actualizado correctamente.',
      );
    }

    return customers;
  }

  String buildCustomerLabel(Customer customer) {
    final companyName = customer.companyName.trim();
    if (companyName.isNotEmpty) {
      return companyName;
    }

    return customer.contactName.trim();
  }
}
