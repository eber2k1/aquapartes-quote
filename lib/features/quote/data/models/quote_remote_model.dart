import '../../domain/entities/quote.dart';
import 'quote_remote_item_model.dart';

class QuoteRemoteModel {
  const QuoteRemoteModel({
    required this.id,
    required this.quoteNumber,
    required this.customerId,
    required this.customerName,
    required this.customerCompany,
    required this.customerPhone,
    required this.createdBy,
    this.createdByUserName,
    required this.issueDate,
    required this.taxPercent,
    required this.currency,
    required this.status,
    required this.pdfFileUrl,
    required this.pdfFileName,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.items,
  });

  final String id;
  final int? quoteNumber;
  final String customerId;
  final String customerName;
  final String customerCompany;
  final String customerPhone;
  final String createdBy;
  final String? createdByUserName;
  final DateTime issueDate;
  final double taxPercent;
  final String currency;
  final String status;
  final String? pdfFileUrl;
  final String? pdfFileName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final List<QuoteRemoteItemModel> items;

  factory QuoteRemoteModel.fromJson(Map<String, dynamic> json) {
    final customerJson = json['customer'] is Map<String, dynamic>
        ? json['customer'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(QuoteRemoteItemModel.fromJson)
              .toList()
        : <QuoteRemoteItemModel>[];

    return QuoteRemoteModel(
      id: _stringValue(json['id']),
      quoteNumber: _intValue(json['quote_number']),
      customerId: _stringValue(json['customer_id']),
      customerName: _firstNonEmpty([
        json['customer_name'],
        json['customer_name_snapshot'],
        customerJson['contact_name'],
        customerJson['name'],
      ]),
      customerCompany: _firstNonEmpty([
        json['customer_company'],
        json['customer_company_snapshot'],
        customerJson['company_name'],
        customerJson['company'],
      ]),
      customerPhone: _firstNonEmpty([
        json['customer_phone'],
        json['customer_phone_snapshot'],
        customerJson['phone'],
      ]),
      createdBy: _stringValue(json['created_by']),
      createdByUserName:
          (json['created_by_user'] as Map<String, dynamic>?)?['first_name']
              as String?,
      issueDate:
          _dateValue(json['issue_date']) ??
          _dateValue(json['created_at']) ??
          DateTime.now(),
      taxPercent:
          _doubleValue(json['tax_percent']) ??
          _doubleValue(json['taxPercent']) ??
          18,
      currency: _firstNonEmpty([json['currency'], 'USD']),
      status: _firstNonEmpty([json['status'], 'draft']),
      pdfFileUrl: _nullableStringValue(json['pdf_file_url']),
      pdfFileName: _nullableStringValue(json['pdf_file_name']),
      createdAt: _dateValue(json['created_at']),
      updatedAt: _dateValue(json['updated_at']),
      deletedAt: _dateValue(json['deleted_at']),
      items: items,
    );
  }

  Quote toEntity() {
    final createdAtValue = createdAt ?? issueDate;

    return Quote(
      id: id.isEmpty ? null : id,
      quoteNumber: quoteNumber,
      createdAt: createdAtValue,
      issueDate: issueDate,
      customerId: customerId.isEmpty ? null : customerId,
      customerName: customerName,
      customerCompany: customerCompany,
      customerPhone: customerPhone,
      items: items.map((item) => item.toEntity()).toList(),
      taxPercent: taxPercent,
      currency: currency,
      status: status,
      pdfFileUrl: pdfFileUrl,
      pdfFileName: pdfFileName,
      createdBy: createdBy,
      createdByUserName: createdByUserName,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  Map<String, dynamic> toCreatePayload({required String createdBy}) {
    return {
      'quote_number': quoteNumber,
      'customer_id': customerId,
      'created_by': createdBy,
      'issue_date': _formatDate(issueDate),
      'tax_percent': taxPercent,
      'currency': currency,
      'status': status,
      'pdf_file_url': pdfFileUrl,
      'items': items.map((item) => item.toPayload()).toList(),
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'quote_number': quoteNumber,
      'customer_id': customerId,
      'issue_date': _formatDate(issueDate),
      'tax_percent': taxPercent,
      'currency': currency,
      'status': status,
      'pdf_file_url': pdfFileUrl,
      'items': items.map((item) => item.toPayload()).toList(),
    };
  }

  static String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String _stringValue(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static String? _nullableStringValue(Object? value) {
    final normalizedValue = value?.toString().replaceAll('`', '').trim();
    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
  }

  static String _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      final normalizedValue = _stringValue(value);
      if (normalizedValue.isNotEmpty) {
        return normalizedValue;
      }
    }

    return '';
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
