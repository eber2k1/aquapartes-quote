import 'dart:convert';

import '../../../../../core/storage/cache_client.dart';
import '../../domain/entities/product.dart';

class CatalogCacheDataSource {
  static const _productsKey = 'products';
  final CacheClient _cache = const CacheClient();

  Future<List<Product>> loadProducts() async {
    final rawProducts = await _cache.getStringList(_productsKey);

    if (rawProducts == null || rawProducts.isEmpty) {
      return [];
    }

    final products = <Product>[];

    for (final item in rawProducts) {
      try {
        products.add(
          Product.fromJson(jsonDecode(item) as Map<String, dynamic>),
        );
      } on FormatException {
        // Ignore malformed cached entries so one bad record does not block the list.
      } on TypeError {
        // Ignore malformed cached entries so one bad record does not block the list.
      }
    }

    return products;
  }

  Future<void> saveProducts(List<Product> products) async {
    final rawProducts = products
        .map((product) => jsonEncode(product.toJson()))
        .toList();

    await _cache.setStringList(_productsKey, rawProducts);
  }
}
