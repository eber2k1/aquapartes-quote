import '../../domain/entities/product.dart';
import '../models/catalog_display_options.dart';

class CatalogProductsViewHelper {
  const CatalogProductsViewHelper._();

  static List<Product> buildVisibleProducts({
    required List<Product> products,
    required String searchQuery,
    required CatalogSortMode sortMode,
  }) {
    final query = searchQuery.trim().toLowerCase();

    final filteredProducts = query.isEmpty
        ? List<Product>.from(products)
        : products.where((product) {
            return product.name.toLowerCase().contains(query) ||
                product.brand.toLowerCase().contains(query) ||
                product.category.toLowerCase().contains(query);
          }).toList();

    switch (sortMode) {
      case CatalogSortMode.nameAsc:
        filteredProducts.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case CatalogSortMode.nameDesc:
        filteredProducts.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case CatalogSortMode.priceAsc:
        filteredProducts.sort((a, b) => a.basePrice.compareTo(b.basePrice));
        break;
      case CatalogSortMode.priceDesc:
        filteredProducts.sort((a, b) => b.basePrice.compareTo(a.basePrice));
        break;
    }

    return filteredProducts;
  }

  static Map<String, List<Product>> groupProducts({
    required List<Product> products,
    required CatalogViewMode viewMode,
  }) {
    final groupedProducts = <String, List<Product>>{};

    for (final product in products) {
      final rawKey = switch (viewMode) {
        CatalogViewMode.brand => product.brand,
        CatalogViewMode.category => product.category,
        CatalogViewMode.loose => '',
      };
      final key = rawKey.trim().isEmpty
          ? (viewMode == CatalogViewMode.brand ? 'Sin marca' : 'Sin categoria')
          : rawKey.trim();

      groupedProducts.putIfAbsent(key, () => []);
      groupedProducts[key]!.add(product);
    }

    return groupedProducts;
  }
}
