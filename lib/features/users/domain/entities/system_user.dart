class SystemUser {
  const SystemUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastNamePaternal,
    required this.lastNameMaternal,
    required this.phone,
    required this.position,
    required this.role,
    required this.isActive,
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

  String get fullName {
    return [
      firstName.trim(),
      lastNamePaternal.trim(),
      lastNameMaternal.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
  }

  SystemUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastNamePaternal,
    String? lastNameMaternal,
    String? phone,
    String? position,
    String? role,
    bool? isActive,
  }) {
    return SystemUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastNamePaternal: lastNamePaternal ?? this.lastNamePaternal,
      lastNameMaternal: lastNameMaternal ?? this.lastNameMaternal,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name_paternal': lastNamePaternal,
      'last_name_maternal': lastNameMaternal,
      'phone': phone,
      'position': position,
      'role': role,
      'is_active': isActive,
    };
  }

  factory SystemUser.fromJson(Map<String, dynamic> json) {
    return SystemUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName:
          json['first_name']?.toString() ?? json['firstName']?.toString() ?? '',
      lastNamePaternal:
          json['last_name_paternal']?.toString() ??
          json['lastNamePaternal']?.toString() ??
          '',
      lastNameMaternal:
          json['last_name_maternal']?.toString() ??
          json['lastNameMaternal']?.toString() ??
          '',
      phone: json['phone']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      role: json['role']?.toString() ?? 'sales',
      isActive: _parseBool(json['is_active'] ?? json['isActive']),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final str = value?.toString().trim().toLowerCase();
    return str == 'true' || str == '1';
  }
}
