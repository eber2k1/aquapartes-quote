import '../../domain/entities/quote.dart';

class QuoteRemoteItemModel {
  const QuoteRemoteItemModel({
    required this.productId,
    required this.itemOrder,
    required this.productNameSnapshot,
    required this.productCategorySnapshot,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final int itemOrder;
  final String productNameSnapshot;
  final String productCategorySnapshot;
  final double unitPrice;
  final int quantity;

  factory QuoteRemoteItemModel.fromJson(Map<String, dynamic> json) {
    return QuoteRemoteItemModel(
      productId: _stringValue(json['product_id']),
      itemOrder:
          _intValue(json['item_order']) ?? _intValue(json['itemOrder']) ?? 0,
      productNameSnapshot:
          _stringValue(json['product_name_snapshot']).isNotEmpty
          ? _stringValue(json['product_name_snapshot'])
          : _stringValue(json['productName']),
      productCategorySnapshot:
          _stringValue(json['product_category_snapshot']).isNotEmpty
          ? _stringValue(json['product_category_snapshot'])
          : _stringValue(json['productCategory']),
      unitPrice:
          _doubleValue(json['unit_price']) ??
          _doubleValue(json['unitPrice']) ??
          0,
      quantity: _intValue(json['quantity']) ?? 0,
    );
  }

  QuoteItem toEntity() {
    return QuoteItem(
      productId: productId.isEmpty ? null : productId,
      itemOrder: itemOrder == 0 ? null : itemOrder,
      productName: productNameSnapshot,
      productCategory: productCategorySnapshot,
      unitPrice: unitPrice,
      quantity: quantity,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'product_id': productId,
      'item_order': itemOrder,
      'product_name_snapshot': productNameSnapshot,
      'product_category_snapshot': productCategorySnapshot,
      'unit_price': unitPrice,
      'quantity': quantity,
    };
  }

  static String _stringValue(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static int? _intValue(Object? value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString().trim() ?? '');
  }

  static double? _doubleValue(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString().trim() ?? '');
  }
}
