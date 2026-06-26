class ProductAttribute {
  const ProductAttribute({
    this.id,
    required this.name,
    required this.value,
    this.sortOrder,
  });

  final String? id;
  final String name;
  final String value;
  final int? sortOrder;

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'value': value, 'sortOrder': sortOrder};
  }

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
      sortOrder: json['sortOrder'] as int?,
    );
  }
}

class Product {
  const Product({
    this.id,
    required this.name,
    required this.basePrice,
    required this.category,
    required this.brand,
    required this.origin,
    required this.model,
    this.imageUrl = '',
    this.imageFileName = '',
    this.technicalSheetUrl = '',
    this.technicalSheetFileName = '',
    this.currency = 'USD',
    this.isActive = true,
    this.createdBy = '',
    this.createdByUserName,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.attributes = const [],
  });

  final String? id;
  final String name;
  final double basePrice;
  final String category;
  final String brand;
  final String origin;
  final String model;
  final String imageUrl;
  final String imageFileName;
  final String technicalSheetUrl;
  final String technicalSheetFileName;
  final String currency;
  final bool isActive;
  final String createdBy;
  final String? createdByUserName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final List<ProductAttribute> attributes;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'basePrice': basePrice,
      'category': category,
      'brand': brand,
      'origin': origin,
      'model': model,
      'imageUrl': imageUrl,
      'imageFileName': imageFileName,
      'technicalSheetUrl': technicalSheetUrl,
      'technicalSheetFileName': technicalSheetFileName,
      'currency': currency,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'attributes': attributes.map((attribute) => attribute.toJson()).toList(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0,
      category: json['category'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      model: json['model'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      imageFileName: json['imageFileName'] as String? ?? '',
      technicalSheetUrl: json['technicalSheetUrl'] as String? ?? '',
      technicalSheetFileName: json['technicalSheetFileName'] as String? ?? '',
      currency: json['currency'] as String? ?? 'USD',
      isActive: json['isActive'] as bool? ?? true,
      createdBy: json['createdBy'] as String? ?? '',
      createdByUserName:
          (json['created_by_user'] as Map<String, dynamic>?)?['first_name']
              as String?,
      createdAt: _dateValue(json['createdAt']),
      updatedAt: _dateValue(json['updatedAt']),
      deletedAt: _dateValue(json['deletedAt']),
      attributes: (json['attributes'] as List<dynamic>? ?? [])
          .map(
            (item) => ProductAttribute.fromJson(item as Map<String, dynamic>),
          )
          .where(
            (attribute) =>
                attribute.name.trim().isNotEmpty &&
                attribute.value.trim().isNotEmpty,
          )
          .toList(),
    );
  }

  Product copyWith({
    String? id,
    String? name,
    double? basePrice,
    String? category,
    String? brand,
    String? origin,
    String? model,
    String? imageUrl,
    String? imageFileName,
    String? technicalSheetUrl,
    String? technicalSheetFileName,
    String? currency,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<ProductAttribute>? attributes,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      basePrice: basePrice ?? this.basePrice,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      origin: origin ?? this.origin,
      model: model ?? this.model,
      imageUrl: imageUrl ?? this.imageUrl,
      imageFileName: imageFileName ?? this.imageFileName,
      technicalSheetUrl: technicalSheetUrl ?? this.technicalSheetUrl,
      technicalSheetFileName:
          technicalSheetFileName ?? this.technicalSheetFileName,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      attributes: attributes ?? this.attributes,
    );
  }

  static DateTime? _dateValue(Object? value) {
    final rawValue = value?.toString().trim();
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawValue);
  }
}
