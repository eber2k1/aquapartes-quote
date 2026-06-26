class UserProfile {
  const UserProfile({
    required this.paternalLastName,
    required this.maternalLastName,
    required this.firstNames,
    required this.phone,
    required this.position,
    required this.email,
  });

  final String paternalLastName;
  final String maternalLastName;
  final String firstNames;
  final String phone;
  final String position;
  final String email;

  Map<String, dynamic> toJson() {
    return {
      'paternalLastName': paternalLastName,
      'maternalLastName': maternalLastName,
      'firstNames': firstNames,
      'phone': phone,
      'position': position,
      'email': email,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      paternalLastName: json['paternalLastName'] as String? ?? '',
      maternalLastName: json['maternalLastName'] as String? ?? '',
      firstNames: json['firstNames'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      position: json['position'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  String get fullName {
    return [
      firstNames.trim(),
      paternalLastName.trim(),
      maternalLastName.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
  }
}
