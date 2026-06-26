import '../../domain/entities/product.dart';

class ProductAttributeRemoteModel {
  const ProductAttributeRemoteModel({
    required this.id,
    required this.productId,
    required this.attributeName,
    required this.attributeValue,
    required this.sortOrder,
  });

  final String id;
  final String productId;
  final String attributeName;
  final String attributeValue;
  final int sortOrder;

  factory ProductAttributeRemoteModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeRemoteModel(
      id: _stringValue(json['id']),
      productId: _stringValue(json['product_id']),
      attributeName: _stringValue(json['attribute_name']),
      attributeValue: _stringValue(json['attribute_value']),
      sortOrder: _intValue(json['sort_order']),
    );
  }

  ProductAttribute toEntity() {
    return ProductAttribute(
      id: id,
      name: attributeName,
      value: attributeValue,
      sortOrder: sortOrder,
    );
  }

  static String _stringValue(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static int _intValue(Object? value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString().trim() ?? '') ?? 0;
  }
}
