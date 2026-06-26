import 'data/datasources/catalog_cache_datasource.dart';
import 'data/datasources/remote/catalog_remote_datasource.dart';
import 'data/repositories/catalog_repository_impl.dart';
import 'domain/repositories/catalog_repository.dart';

final CatalogRepository _catalogRepository = CatalogRepositoryImpl(
  remoteDataSource: CatalogRemoteDataSource(),
  cacheDataSource: CatalogCacheDataSource(),
);

CatalogRepository getCatalogRepository() => _catalogRepository;
