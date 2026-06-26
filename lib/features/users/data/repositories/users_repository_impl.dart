import '../../domain/entities/system_user.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/remote/users_remote_datasource.dart';

class UsersRepositoryImpl implements UsersRepository {
  UsersRepositoryImpl({required this.remoteDataSource});

  final UsersRemoteDataSource remoteDataSource;

  @override
  Future<List<SystemUser>> loadUsers() {
    return remoteDataSource.fetchUsers();
  }

  @override
  Future<SystemUser> getUserById(String id) {
    return remoteDataSource.fetchUserById(id);
  }

  @override
  Future<SystemUser> createUser(SystemUser user, {String? password}) {
    return remoteDataSource.createUser(user, password: password);
  }

  @override
  Future<SystemUser> updateUser(SystemUser user, {String? password}) {
    return remoteDataSource.updateUser(user, password: password);
  }

  @override
  Future<void> deleteUser(String id) {
    return remoteDataSource.deleteUser(id);
  }
}