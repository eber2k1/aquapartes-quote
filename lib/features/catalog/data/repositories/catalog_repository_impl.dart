import '../../../../core/models/repository_load_result.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/stored_file.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_cache_datasource.dart';
import '../datasources/remote/catalog_remote_datasource.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl({
    required this._remoteDataSource,
    required this._cacheDataSource,
  });

  final CatalogRemoteDataSource _remoteDataSource;
  final CatalogCacheDataSource _cacheDataSource;

  @override
  Future<RepositoryLoadResult<List<Product>>> loadProducts() async {
    try {
      final products = await _remoteDataSource.fetchProducts();
      await _cacheDataSource.saveProducts(products);
      return RepositoryLoadResult(data: products, fromCache: false);
    } catch (error) {
      final cachedProducts = await _cacheDataSource.loadProducts();
      return RepositoryLoadResult(
        data: cachedProducts,
        fromCache: true,
        errorMessage: error.toString(),
      );
    }
  }

  @override
  Future<List<Product>> loadCachedProducts() {
    return _cacheDataSource.loadProducts();
  }

  @override
  Future<void> saveCachedProducts(List<Product> products) {
    return _cacheDataSource.saveProducts(products);
  }

  @override
  Future<Product> createProduct(Product product) {
    return _remoteDataSource.createProduct(product);
  }

  @override
  Future<Product> updateProduct(Product product) {
    return _remoteDataSource.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(String productId) {
    return _remoteDataSource.deleteProduct(productId);
  }

  @override
  Future<List<StoredFile>> fetchProductImageFiles() async {
    return _remoteDataSource.fetchProductImageFiles();
  }

  @override
  Future<List<StoredFile>> fetchTechnicalSheetFiles() async {
    return _remoteDataSource.fetchTechnicalSheetFiles();
  }

  @override
  Future<String> uploadGenericProductImage(String filePath) {
    return _remoteDataSource.uploadGenericProductImage(filePath);
  }

  @override
  Future<String> uploadGenericTechnicalSheet(String filePath) {
    return _remoteDataSource.uploadGenericTechnicalSheet(filePath);
  }

  @override
  Future<void> deleteGenericProductImage(String url) {
    return _remoteDataSource.deleteGenericProductImage(url);
  }

  @override
  Future<void> deleteGenericTechnicalSheet(String url) {
    return _remoteDataSource.deleteGenericTechnicalSheet(url);
  }
}
