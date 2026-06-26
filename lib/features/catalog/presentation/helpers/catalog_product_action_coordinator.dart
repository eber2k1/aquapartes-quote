import '../../../../core/services/app_notifications.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../models/product_form_result.dart';

class CatalogProductActionCoordinator {
  CatalogProductActionCoordinator({required this.repository});

  final CatalogRepository repository;

  Future<List<Product>> applyResult({
    required List<Product> currentProducts,
    required ProductFormResult result,
    Product? initialProduct,
    int? index,
  }) async {
    final products = List<Product>.from(currentProducts);
    final deletedProductName = initialProduct?.name;

    Product? savedProduct;

    if (result.isDeleted) {
      final productId = initialProduct?.id?.trim() ?? '';
      if (productId.isNotEmpty) {
        await repository.deleteProduct(productId);
      }

      if (index != null && index >= 0 && index < products.length) {
        products.removeAt(index);
      }
    } else if (result.product != null) {
      final productToPersist = result.product!.copyWith(
        id: initialProduct?.id,
        currency: initialProduct?.currency ?? result.product!.currency,
        isActive: initialProduct?.isActive ?? result.product!.isActive,
        createdBy: initialProduct?.createdBy ?? result.product!.createdBy,
        createdAt: initialProduct?.createdAt ?? result.product!.createdAt,
      );

      savedProduct = index == null
          ? await repository.createProduct(productToPersist)
          : await repository.updateProduct(productToPersist);

      if (index == null) {
        products.add(savedProduct);
      } else if (index >= 0 && index < products.length) {
        products[index] = savedProduct;
      }
    }

    await repository.saveCachedProducts(products);

    if (result.isDeleted && deletedProductName != null) {
      AppNotifications.showDelete(
        'Producto "$deletedProductName" eliminado correctamente.',
      );
      return products;
    }

    if (savedProduct != null) {
      AppNotifications.showSuccess(
        index == null
            ? 'Producto "${savedProduct.name}" creado correctamente.'
            : 'Producto "${savedProduct.name}" actualizado correctamente.',
      );
    }

    return products;
  }
}
