import '../../domain/entities/customer.dart';

class CustomerRemoteModel {
  const CustomerRemoteModel({
    required this.id,
    required this.companyName,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.address,
    required this.createdBy,
    this.createdByUserName,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String companyName;
  final String contactName;
  final String phone;
  final String email;
  final String address;
  final String createdBy;
  final String? createdByUserName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  factory CustomerRemoteModel.fromJson(Map<String, dynamic> json) {
    return CustomerRemoteModel(
      id: _stringValue(json['id']),
      companyName: _stringValue(json['company_name']),
      contactName: _stringValue(json['contact_name']),
      phone: _stringValue(json['phone']),
      email: _stringValue(json['email']),
      address: _stringValue(json['address']),
      createdBy: _stringValue(json['created_by']),
      createdByUserName:
          (json['created_by_user'] as Map<String, dynamic>?)?['first_name']
              as String?,
      createdAt: _dateValue(json['created_at']),
      updatedAt: _dateValue(json['updated_at']),
      deletedAt: _dateValue(json['deleted_at']),
    );
  }

  Customer toEntity() {
    return Customer(
      id: id,
      companyName: companyName,
      contactName: contactName,
      phone: phone,
      email: email,
      address: address,
      createdBy: createdBy,
      createdByUserName: createdByUserName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  Map<String, dynamic> toCreatePayload({required String createdBy}) {
    return {
      'company_name': companyName,
      'contact_name': contactName,
      'phone': phone,
      'email': email.isEmpty ? null : email,
      'address': address.isEmpty ? null : address,
      'created_by': createdBy,
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'company_name': companyName,
      'contact_name': contactName,
      'phone': phone,
      'email': email.isEmpty ? null : email,
      'address': address.isEmpty ? null : address,
    };
  }

  static String _stringValue(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static DateTime? _dateValue(Object? value) {
    final rawValue = value?.toString().trim();
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawValue);
  }
}
