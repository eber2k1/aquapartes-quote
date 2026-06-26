import '../../domain/entities/product.dart';

class ProductRemoteModel {
  const ProductRemoteModel({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.origin,
    required this.model,
    required this.imageUrl,
    required this.imageFileName,
    required this.technicalSheetUrl,
    required this.technicalSheetFileName,
    required this.basePrice,
    required this.currency,
    required this.isActive,
    required this.createdBy,
    this.createdByUserName,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String name;
  final String category;
  final String brand;
  final String origin;
  final String model;
  final String imageUrl;
  final String imageFileName;
  final String technicalSheetUrl;
  final String technicalSheetFileName;
  final double basePrice;
  final String currency;
  final bool isActive;
  final String createdBy;
  final String? createdByUserName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  factory ProductRemoteModel.fromJson(Map<String, dynamic> json) {
    return ProductRemoteModel(
      id: _stringValue(json['id']),
      name: _stringValue(json['name']),
      category: _stringValue(json['category']),
      brand: _stringValue(json['brand']),
      origin: _stringValue(json['origin']),
      model: _stringValue(json['model']),
      imageUrl: _cleanUrl(json['image_url']),
      imageFileName: _stringValue(json['image_file_name']),
      technicalSheetUrl: _cleanUrl(json['technical_sheet_url']),
      technicalSheetFileName: _stringValue(json['technical_sheet_file_name']),
      basePrice: _doubleValue(json['base_price']),
      currency: _stringValue(json['currency']),
      isActive: _boolValue(json['is_active']),
      createdBy: _stringValue(json['created_by']),
      createdByUserName:
          (json['created_by_user'] as Map<String, dynamic>?)?['first_name']
              as String?,
      createdAt: _dateValue(json['created_at']),
      updatedAt: _dateValue(json['updated_at']),
      deletedAt: _dateValue(json['deleted_at']),
    );
  }

  Product toEntity({List<ProductAttribute> attributes = const []}) {
    return Product(
      id: id,
      name: name,
      basePrice: basePrice,
      category: category,
      brand: brand,
      origin: origin,
      model: model,
      imageUrl: imageUrl,
      imageFileName: imageFileName,
      technicalSheetUrl: technicalSheetUrl,
      technicalSheetFileName: technicalSheetFileName,
      currency: currency,
      isActive: isActive,
      createdBy: createdBy,
      createdByUserName: createdByUserName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      attributes: attributes,
    );
  }

  Map<String, dynamic> toCreatePayload({required String createdBy}) {
    return {
      'name': name,
      'category': category,
      'brand': brand,
      'origin': origin,
      'model': model,
      'image_url': imageUrl.isEmpty ? null : imageUrl,
      'technical_sheet_url': technicalSheetUrl.isEmpty
          ? null
          : technicalSheetUrl,
      'base_price': basePrice,
      'currency': currency,
      'is_active': isActive ? 1 : 0,
      'created_by': createdBy,
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'name': name,
      'category': category,
      'brand': brand,
      'origin': origin,
      'model': model,
      'image_url': imageUrl.isEmpty ? null : imageUrl,
      'technical_sheet_url': technicalSheetUrl.isEmpty
          ? null
          : technicalSheetUrl,
      'base_price': basePrice,
      'currency': currency,
      'is_active': isActive ? 1 : 0,
    };
  }

  static String _stringValue(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static String _cleanUrl(Object? value) {
    return _stringValue(value).replaceAll('`', '').trim();
  }

  static double _doubleValue(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString().trim() ?? '') ?? 0;
  }

  static bool _boolValue(Object? value) {
    if (value is bool) {
      return value;
    }

    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == '1' || normalized == 'true';
  }

  static DateTime? _dateValue(Object? value) {
    final rawValue = value?.toString().trim();
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawValue);
  }
}
