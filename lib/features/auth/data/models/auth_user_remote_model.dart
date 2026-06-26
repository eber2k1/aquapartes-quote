import '../../domain/entities/auth_user.dart';

class AuthUserRemoteModel {
  const AuthUserRemoteModel({
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

  factory AuthUserRemoteModel.fromJson(Map<String, dynamic> json) {
    final entity = AuthUser.fromJson(json);
    return AuthUserRemoteModel(
      id: entity.id,
      email: entity.email,
      firstName: entity.firstName,
      lastNamePaternal: entity.lastNamePaternal,
      lastNameMaternal: entity.lastNameMaternal,
      phone: entity.phone,
      position: entity.position,
      role: entity.role,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      email: email,
      firstName: firstName,
      lastNamePaternal: lastNamePaternal,
      lastNameMaternal: lastNameMaternal,
      phone: phone,
      position: position,
      role: role,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
