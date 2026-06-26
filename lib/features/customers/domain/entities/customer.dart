class Customer {
  const Customer({
    this.id,
    required this.contactName,
    required this.phone,
    required this.companyName,
    required this.email,
    required this.address,
    this.createdBy = '',
    this.createdByUserName,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String? id;
  final String contactName;
  final String phone;
  final String companyName;
  final String email;
  final String address;
  final String createdBy;
  final String? createdByUserName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  // Legacy aliases to keep the rest of the app readable while migrating.
  String get name => contactName;
  String get company => companyName;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactName': contactName,
      'phone': phone,
      'companyName': companyName,
      'email': email,
      'address': address,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String?,
      contactName:
          json['contact_name'] as String? ??
          json['contactName'] as String? ??
          json['name'] as String? ??
          '',
      phone: json['phone'] as String? ?? '',
      companyName:
          json['company_name'] as String? ??
          json['companyName'] as String? ??
          json['company'] as String? ??
          '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      createdBy:
          json['created_by'] as String? ?? json['createdBy'] as String? ?? '',
      createdByUserName:
          (json['created_by_user'] as Map<String, dynamic>?)?['first_name']
              as String?,
      createdAt: _dateValue(json['created_at'] ?? json['createdAt']),
      updatedAt: _dateValue(json['updated_at'] ?? json['updatedAt']),
      deletedAt: _dateValue(json['deleted_at'] ?? json['deletedAt']),
    );
  }

  Customer copyWith({
    String? id,
    String? contactName,
    String? phone,
    String? companyName,
    String? email,
    String? address,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      address: address ?? this.address,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
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
}
