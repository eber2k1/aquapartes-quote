import '../entities/system_user.dart';

abstract class UsersRepository {
  Future<List<SystemUser>> loadUsers();
  Future<SystemUser> getUserById(String id);
  Future<SystemUser> createUser(SystemUser user, {String? password});
  Future<SystemUser> updateUser(SystemUser user, {String? password});
  Future<void> deleteUser(String id);
}