import 'dart:convert';

import '../../../../../core/storage/cache_client.dart';
import '../../domain/entities/customer.dart';

class CustomersCacheDataSource {
  static const _customersKey = 'customers';
  final CacheClient _cache = const CacheClient();

  Future<List<Customer>> loadCustomers() async {
    final rawCustomers = await _cache.getStringList(_customersKey);

    if (rawCustomers == null || rawCustomers.isEmpty) {
      return [];
    }

    final customers = <Customer>[];

    for (final item in rawCustomers) {
      try {
        customers.add(
          Customer.fromJson(jsonDecode(item) as Map<String, dynamic>),
        );
      } on FormatException {
        // Ignore malformed cached entries so one bad record does not block the list.
      } on TypeError {
        // Ignore malformed cached entries so one bad record does not block the list.
      }
    }

    return customers;
  }

  Future<void> saveCustomers(List<Customer> customers) async {
    final rawCustomers = customers
        .map((customer) => jsonEncode(customer.toJson()))
        .toList();

    await _cache.setStringList(_customersKey, rawCustomers);
  }
}
