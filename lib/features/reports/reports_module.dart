import 'data/datasources/remote/reports_remote_datasource.dart';
import 'data/repositories/reports_repository_impl.dart';
import 'domain/repositories/reports_repository.dart';

ReportsRepository? _reportsRepository;

void initReportsModule() {
  final remoteDataSource = ReportsRemoteDataSource();
  _reportsRepository = ReportsRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
}

ReportsRepository getReportsRepository() {
  if (_reportsRepository == null) {
    initReportsModule();
  }
  return _reportsRepository!;
}
