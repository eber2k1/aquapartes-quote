class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastNamePaternal,
    required this.lastNameMaternal,
    required this.phone,
    required this.position,
    required this.role,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastNamePaternal;
  final String lastNameMaternal;
  final String phone;
  final String position;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get fullName {
    return [
      firstName.trim(),
      lastNamePaternal.trim(),
      lastNameMaternal.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastNamePaternal': lastNamePaternal,
      'lastNameMaternal': lastNameMaternal,
      'phone': phone,
      'position': position,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName:
          json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastNamePaternal:
          json['lastNamePaternal'] as String? ??
          json['last_name_paternal'] as String? ??
          '',
      lastNameMaternal:
          json['lastNameMaternal'] as String? ??
          json['last_name_maternal'] as String? ??
          '',
      phone: json['phone'] as String? ?? '',
      position: json['position'] as String? ?? '',
      role: json['role'] as String? ?? '',
      isActive: _boolValue(json['isActive'] ?? json['is_active']),
      createdAt: _dateValue(json['createdAt'] ?? json['created_at']),
      updatedAt: _dateValue(json['updatedAt'] ?? json['updated_at']),
    );
  }

  static bool _boolValue(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }

    final normalized = value?.toString().trim().toLowerCase();
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
