import 'data/datasources/remote/users_remote_datasource.dart';
import 'data/repositories/users_repository_impl.dart';
import 'domain/repositories/users_repository.dart';

UsersRepository? _usersRepository;

UsersRepository getUsersRepository() {
  _usersRepository ??= UsersRepositoryImpl(
    remoteDataSource: UsersRemoteDataSource(),
  );
  return _usersRepository!;
}