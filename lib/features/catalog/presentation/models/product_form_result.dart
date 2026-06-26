import '../../domain/entities/product.dart';

class ProductFormResult {
  const ProductFormResult._({this.product, required this.isDeleted});

  const ProductFormResult.saved(Product product)
    : this._(product: product, isDeleted: false);

  const ProductFormResult.deleted() : this._(isDeleted: true);

  final Product? product;
  final bool isDeleted;
}
