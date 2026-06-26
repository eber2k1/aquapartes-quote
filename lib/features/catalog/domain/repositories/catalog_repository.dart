import '../../../../core/models/repository_load_result.dart';
import '../entities/product.dart';
import '../entities/stored_file.dart';

abstract class CatalogRepository {
  Future<RepositoryLoadResult<List<Product>>> loadProducts();
  Future<List<Product>> loadCachedProducts();
  Future<void> saveCachedProducts(List<Product> products);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String productId);
  Future<List<StoredFile>> fetchProductImageFiles();
  Future<List<StoredFile>> fetchTechnicalSheetFiles();
  Future<String> uploadGenericProductImage(String filePath);
  Future<String> uploadGenericTechnicalSheet(String filePath);
  Future<void> deleteGenericProductImage(String url);
  Future<void> deleteGenericTechnicalSheet(String url);
}
