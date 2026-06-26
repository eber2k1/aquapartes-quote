class QuoteItem {
  const QuoteItem({
    this.productId,
    this.itemOrder,
    required this.productName,
    required this.productCategory,
    required this.unitPrice,
    required this.quantity,
  });

  final String? productId;
  final int? itemOrder;
  final String productName;
  final String productCategory;
  final double unitPrice;
  final int quantity;

  double get subtotal => unitPrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'itemOrder': itemOrder,
      'productName': productName,
      'productCategory': productCategory,
      'unitPrice': unitPrice,
      'quantity': quantity,
    };
  }

  factory QuoteItem.fromJson(Map<String, dynamic> json) {
    return QuoteItem(
      productId: json['productId'] as String? ?? json['product_id'] as String?,
      itemOrder: _intValue(json['itemOrder']) ?? _intValue(json['item_order']),
      productName: json['productName'] as String? ?? '',
      productCategory: json['productCategory'] as String? ?? '',
      unitPrice: _doubleValue(json['unitPrice']) ?? 0,
      quantity: _intValue(json['quantity']) ?? 0,
    );
  }

  QuoteItem copyWith({
    String? productId,
    int? itemOrder,
    String? productName,
    String? productCategory,
    double? unitPrice,
    int? quantity,
  }) {
    return QuoteItem(
      productId: productId ?? this.productId,
      itemOrder: itemOrder ?? this.itemOrder,
      productName: productName ?? this.productName,
      productCategory: productCategory ?? this.productCategory,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
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

class Quote {
  const Quote({
    this.id,
    this.quoteNumber,
    required this.createdAt,
    DateTime? issueDate,
    this.customerId,
    required this.customerName,
    required this.customerCompany,
    required this.customerPhone,
    required this.items,
    this.taxPercent = 18,
    this.currency = 'USD',
    this.status = 'draft',
    this.pdfFileUrl,
    this.pdfFileName,
    this.createdBy = '',
    this.createdByUserName,
    this.updatedAt,
    this.deletedAt,
  }) : issueDate = issueDate ?? createdAt;

  final String? id;
  final int? quoteNumber;
  final DateTime createdAt;
  final DateTime issueDate;
  final String? customerId;
  final String customerName;
  final String customerCompany;
  final String customerPhone;
  final List<QuoteItem> items;
  final double taxPercent;
  final String currency;
  final String status;
  final String? pdfFileUrl;
  final String? pdfFileName;
  final String createdBy;
  final String? createdByUserName;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get taxableAmount => subtotal;

  double get igvAmount => taxableAmount * (taxPercent / 100);

  double get total => taxableAmount + igvAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quoteNumber': quoteNumber,
      'createdAt': createdAt.toIso8601String(),
      'issueDate': issueDate.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'customerCompany': customerCompany,
      'customerPhone': customerPhone,
      'taxPercent': taxPercent,
      'currency': currency,
      'status': status,
      'pdfFileUrl': pdfFileUrl,
      'pdfFileName': pdfFileName,
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .map((item) => QuoteItem.fromJson(item as Map<String, dynamic>))
              .toList()
        : <QuoteItem>[];

    // Backward compatibility with the old one-product quote shape.
    final migratedItems = items.isNotEmpty
        ? items
        : [
            QuoteItem(
              productName: json['productName'] as String? ?? '',
              productCategory: json['productCategory'] as String? ?? '',
              unitPrice: _doubleValue(json['unitPrice']) ?? 0,
              quantity: _intValue(json['quantity']) ?? 0,
            ),
          ].where((item) => item.productName.isNotEmpty).toList();

    return Quote(
      id: json['id'] as String?,
      quoteNumber:
          _intValue(json['quoteNumber']) ?? _intValue(json['quote_number']),
      createdAt:
          _dateValue(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
      issueDate:
          _dateValue(json['issueDate'] ?? json['issue_date']) ??
          _dateValue(json['createdAt'] ?? json['created_at']) ??
          DateTime.now(),
      customerId:
          json['customerId'] as String? ?? json['customer_id'] as String?,
      customerName:
          json['customerName'] as String? ??
          (json['customer_info'] as Map<String, dynamic>?)?['contact_name']
              as String? ??
          '',
      customerCompany:
          json['customerCompany'] as String? ??
          (json['customer_info'] as Map<String, dynamic>?)?['company_name']
              as String? ??
          '',
      customerPhone: json['customerPhone'] as String? ?? '',
      taxPercent:
          _doubleValue(json['taxPercent']) ??
          _doubleValue(json['tax_percent']) ??
          18,
      currency: json['currency'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'draft',
      pdfFileUrl:
          json['pdfFileUrl'] as String? ?? json['pdf_file_url'] as String?,
      pdfFileName:
          json['pdfFileName'] as String? ?? json['pdf_file_name'] as String?,
      createdBy:
          json['createdBy'] as String? ?? json['created_by'] as String? ?? '',
      createdByUserName:
          (json['created_by_user'] as Map<String, dynamic>?)?['first_name']
              as String?,
      updatedAt: _dateValue(json['updatedAt'] ?? json['updated_at']),
      deletedAt: _dateValue(json['deletedAt'] ?? json['deleted_at']),
      items: migratedItems,
    );
  }

  Quote copyWith({
    String? id,
    int? quoteNumber,
    DateTime? createdAt,
    DateTime? issueDate,
    String? customerId,
    String? customerName,
    String? customerCompany,
    String? customerPhone,
    List<QuoteItem>? items,
    double? taxPercent,
    String? currency,
    String? status,
    String? pdfFileUrl,
    String? pdfFileName,
    String? createdBy,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Quote(
      id: id ?? this.id,
      quoteNumber: quoteNumber ?? this.quoteNumber,
      createdAt: createdAt ?? this.createdAt,
      issueDate: issueDate ?? this.issueDate,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerCompany: customerCompany ?? this.customerCompany,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      taxPercent: taxPercent ?? this.taxPercent,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      pdfFileUrl: pdfFileUrl ?? this.pdfFileUrl,
      pdfFileName: pdfFileName ?? this.pdfFileName,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  static DateTime? _dateValue(Object? value) {
    final rawValue = value?.toString().trim();
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawValue);
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
