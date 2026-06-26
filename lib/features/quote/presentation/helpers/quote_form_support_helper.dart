import 'package:flutter/material.dart';

import '../../../../core/services/app_notifications.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../../../catalog/presentation/models/product_form_result.dart';
import '../../../catalog/presentation/pages/product_form_page.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/domain/repositories/customers_repository.dart';
import '../../../customers/presentation/models/customer_form_result.dart';
import '../../../customers/presentation/pages/customer_form_page.dart';
import '../../domain/entities/quote.dart';

class QuoteFormDependencies {
  const QuoteFormDependencies({
    required this.customers,
    required this.products,
    required this.hydratedItems,
    required this.selectedCustomer,
    required this.selectedProduct,
    required this.customerText,
    required this.productText,
  });

  final List<Customer> customers;
  final List<Product> products;
  final List<QuoteItem> hydratedItems;
  final Customer? selectedCustomer;
  final Product? selectedProduct;
  final String customerText;
  final String productText;
}

class QuoteFormSelectionUpdate<T> {
  const QuoteFormSelectionUpdate({
    required this.items,
    required this.selectedItem,
  });

  final List<T> items;
  final T selectedItem;
}

class QuoteFormSupportHelper {
  QuoteFormSupportHelper({
    required this.catalogRepository,
    required this.customersRepository,
  });

  final CatalogRepository catalogRepository;
  final CustomersRepository customersRepository;

  Future<QuoteFormDependencies> loadDependencies({
    required Quote? initialQuote,
    required List<QuoteItem> initialItems,
  }) async {
    final customersResult = await customersRepository.loadCustomers();
    final productsResult = await catalogRepository.loadProducts();
    final customers = List<Customer>.from(customersResult.data);
    final products = List<Product>.from(productsResult.data);

    if (initialQuote != null) {
      final existingCustomer = customers.cast<Customer?>().firstWhere(
        (customer) => matchesCustomerToQuote(customer, initialQuote),
        orElse: () => null,
      );

      if (existingCustomer == null) {
        customers.add(
          Customer(
            id: initialQuote.customerId,
            contactName: initialQuote.customerName,
            phone: initialQuote.customerPhone,
            companyName: initialQuote.customerCompany,
            email: '',
            address: '',
          ),
        );
      }

      for (final item in initialQuote.items) {
        final alreadyExists = products.any(
          (product) =>
              product.name == item.productName &&
              product.category == item.productCategory &&
              product.basePrice == item.unitPrice,
        );

        if (!alreadyExists) {
          products.add(
            Product(
              id: item.productId,
              name: item.productName,
              basePrice: item.unitPrice,
              category: item.productCategory,
              brand: '',
              origin: '',
              model: '',
              attributes: const [],
            ),
          );
        }
      }
    }

    final hydratedItems = hydrateQuoteItems(initialItems, products);
    final selectedCustomer = resolveInitialCustomer(
      initialQuote: initialQuote,
      customers: customers,
    );
    final selectedProduct = resolveInitialProduct(
      initialQuote: initialQuote,
      products: products,
    );

    return QuoteFormDependencies(
      customers: customers,
      products: products,
      hydratedItems: hydratedItems,
      selectedCustomer: selectedCustomer,
      selectedProduct: selectedProduct,
      customerText: selectedCustomer == null
          ? ''
          : customerLabel(selectedCustomer),
      productText: selectedProduct == null ? '' : productLabel(selectedProduct),
    );
  }

  Future<QuoteFormSelectionUpdate<Customer>?> createCustomer({
    required BuildContext context,
    required List<Customer> currentCustomers,
  }) async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<CustomerFormResult>(
      MaterialPageRoute(builder: (_) => const CustomerFormPage()),
    );

    if (result?.customer == null || !context.mounted) {
      return null;
    }

    try {
      final customer = await customersRepository.createCustomer(
        result!.customer!,
      );
      final updatedCustomers = [...currentCustomers, customer];
      await customersRepository.saveCachedCustomers(updatedCustomers);

      if (context.mounted) {
        AppNotifications.showSuccess(
          'Cliente "${customerLabel(customer)}" creado correctamente.',
        );
      }

      return QuoteFormSelectionUpdate(
        items: updatedCustomers,
        selectedItem: customer,
      );
    } catch (_) {
      if (context.mounted) {
        showMessage(context, 'No se pudo guardar el cliente en la API.');
      }
      return null;
    }
  }

  Future<QuoteFormSelectionUpdate<Product>?> createProduct({
    required BuildContext context,
    required List<Product> currentProducts,
  }) async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<ProductFormResult>(
      MaterialPageRoute(
        builder: (_) => ProductFormPage(existingProducts: currentProducts),
      ),
    );

    if (result?.product == null || !context.mounted) {
      return null;
    }

    try {
      final createdProduct = await catalogRepository.createProduct(
        result!.product!,
      );
      final updatedProducts = [...currentProducts, createdProduct];
      await catalogRepository.saveCachedProducts(updatedProducts);

      return QuoteFormSelectionUpdate(
        items: updatedProducts,
        selectedItem: createdProduct,
      );
    } catch (_) {
      if (context.mounted) {
        showMessage(context, 'No se pudo crear el producto en la API.');
      }
      return null;
    }
  }

  void showMessage(BuildContext context, String message) {
    AppNotifications.showInfo(message);
  }

  bool matchesCustomerToQuote(Customer? customer, Quote quote) {
    if (customer == null) {
      return false;
    }

    final quoteCustomerId = quote.customerId?.trim() ?? '';
    final customerId = customer.id?.trim() ?? '';
    if (quoteCustomerId.isNotEmpty && quoteCustomerId == customerId) {
      return true;
    }

    return customer.contactName == quote.customerName &&
        customer.phone == quote.customerPhone &&
        customer.companyName == quote.customerCompany;
  }

  List<QuoteItem> hydrateQuoteItems(
    List<QuoteItem> items,
    List<Product> products,
  ) {
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final matchedProduct = resolveProductForItem(item, products);

      return item.copyWith(
        productId: matchedProduct?.id ?? item.productId,
        itemOrder: index + 1,
      );
    }).toList();
  }

  Customer? resolveInitialCustomer({
    required Quote? initialQuote,
    required List<Customer> customers,
  }) {
    if (initialQuote == null) {
      return null;
    }

    for (final customer in customers) {
      if (matchesCustomerToQuote(customer, initialQuote)) {
        return customer;
      }
    }

    return null;
  }

  Product? resolveInitialProduct({
    required Quote? initialQuote,
    required List<Product> products,
  }) {
    if (initialQuote == null || initialQuote.items.isEmpty) {
      return null;
    }

    return resolveProductForItem(initialQuote.items.first, products);
  }

  Product? resolveProductForItem(QuoteItem item, List<Product> products) {
    final itemProductId = item.productId?.trim() ?? '';

    for (final product in products) {
      final productId = product.id?.trim() ?? '';
      if (itemProductId.isNotEmpty && itemProductId == productId) {
        return product;
      }

      if (product.name == item.productName &&
          product.category == item.productCategory &&
          product.basePrice == item.unitPrice) {
        return product;
      }
    }

    return null;
  }

  String customerLabel(Customer customer) {
    final companyName = customer.companyName.trim();
    final contactName = customer.contactName.trim();

    if (companyName.isEmpty) {
      return contactName;
    }

    if (contactName.isEmpty) {
      return companyName;
    }

    return '$companyName - $contactName';
  }

  String productLabel(Product product) {
    final category = product.category.trim();
    return category.isEmpty ? product.name : '${product.name} - $category';
  }

  Iterable<Customer> filterCustomers(
    List<Customer> customers,
    String rawQuery,
  ) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return customers.take(8);
    }

    return customers
        .where((customer) {
          return _matchesQuery(customer.contactName, query) ||
              _matchesQuery(customer.companyName, query) ||
              _matchesQuery(customerLabel(customer), query);
        })
        .take(8);
  }

  Iterable<Product> filterProducts(List<Product> products, String rawQuery) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return products.take(8);
    }

    return products
        .where((product) {
          return _matchesQuery(product.name, query) ||
              _matchesQuery(product.category, query) ||
              _matchesQuery(product.brand, query) ||
              _matchesQuery(productLabel(product), query);
        })
        .take(8);
  }

  Customer? findCustomerFromInput(List<Customer> customers, String rawInput) {
    final query = rawInput.trim().toLowerCase();
    if (query.isEmpty) {
      return null;
    }

    for (final customer in customers) {
      if (customerLabel(customer).trim().toLowerCase() == query ||
          customer.contactName.trim().toLowerCase() == query ||
          customer.companyName.trim().toLowerCase() == query) {
        return customer;
      }
    }

    return null;
  }

  Product? findProductFromInput(List<Product> products, String rawInput) {
    final query = rawInput.trim().toLowerCase();
    if (query.isEmpty) {
      return null;
    }

    for (final product in products) {
      if (productLabel(product).trim().toLowerCase() == query ||
          product.name.trim().toLowerCase() == query) {
        return product;
      }
    }

    return null;
  }

  bool _matchesQuery(String source, String query) {
    return source.toLowerCase().contains(query);
  }
}
