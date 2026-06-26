import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response_reader.dart';
import '../../../domain/entities/stored_file.dart';
import '../../../domain/entities/product.dart';
import '../../models/product_attribute_remote_model.dart';
import '../../models/product_remote_model.dart';

class CatalogRemoteDataSource {
  CatalogRemoteDataSource({ApiClient? apiClient})
    : _apiUserId = const String.fromEnvironment('API_USER_ID'),
      _apiClient = apiClient ?? ApiClient();

  final String _apiUserId;
  final ApiClient _apiClient;

  Future<List<Product>> fetchProducts() async {
    final response = await _apiClient.get('/api/products');
    _apiClient.validateResponse(response, 'obtener los productos');
    final items = ApiResponseReader.readDataItems(response);

    final remoteProducts = items
        .whereType<Map<String, dynamic>>()
        .map(ProductRemoteModel.fromJson)
        .where((product) => product.deletedAt == null && product.isActive)
        .toList();

    final remoteAttributes = await fetchProductAttributes();
    final attributesByProductId = <String, List<ProductAttribute>>{};

    for (final attribute in remoteAttributes) {
      attributesByProductId
          .putIfAbsent(attribute.productId, () => [])
          .add(attribute.toEntity());
    }

    for (final attributes in attributesByProductId.values) {
      attributes.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
    }

    return remoteProducts
        .map(
          (product) => product.toEntity(
            attributes: attributesByProductId[product.id] ?? const [],
          ),
        )
        .toList();
  }

  Future<Product> createProduct(Product product) async {
    final createdBy = product.createdBy.trim().isNotEmpty
        ? product.createdBy.trim()
        : _apiUserId.trim();
    if (createdBy.isEmpty) {
      throw Exception(
        'Falta configurar API_USER_ID para crear productos en el backend.',
      );
    }

    final remoteModel = ProductRemoteModel(
      id: product.id ?? '',
      name: product.name,
      category: product.category,
      brand: product.brand,
      origin: product.origin,
      model: product.model,
      imageUrl: product.imageUrl,
      imageFileName: product.imageFileName,
      technicalSheetUrl: product.technicalSheetUrl,
      technicalSheetFileName: product.technicalSheetFileName,
      basePrice: product.basePrice,
      currency: product.currency,
      isActive: product.isActive,
      createdBy: createdBy,
      createdByUserName: product.createdByUserName,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      deletedAt: product.deletedAt,
    );

    final response = await _apiClient.post(
      '/api/products',
      body: remoteModel.toCreatePayload(createdBy: createdBy),
    );

    _apiClient.validateResponse(response, 'crear el producto');

    final createdProduct = ProductRemoteModel.fromJson(
      _readResponseData(response, 'crear el producto'),
    ).toEntity();

    final syncedAttributes = await _replaceProductAttributes(
      productId: createdProduct.id!,
      attributes: product.attributes,
    );

    return createdProduct.copyWith(attributes: syncedAttributes);
  }

  Future<Product> updateProduct(Product product) async {
    final productId = product.id?.trim() ?? '';
    if (productId.isEmpty) {
      throw Exception('No se puede actualizar un producto sin id remoto.');
    }

    final remoteModel = ProductRemoteModel(
      id: productId,
      name: product.name,
      category: product.category,
      brand: product.brand,
      origin: product.origin,
      model: product.model,
      imageUrl: product.imageUrl,
      imageFileName: product.imageFileName,
      technicalSheetUrl: product.technicalSheetUrl,
      technicalSheetFileName: product.technicalSheetFileName,
      basePrice: product.basePrice,
      currency: product.currency,
      isActive: product.isActive,
      createdBy: product.createdBy,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      deletedAt: product.deletedAt,
    );

    final response = await _apiClient.put(
      '/api/products/$productId',
      body: remoteModel.toUpdatePayload(),
    );

    _apiClient.validateResponse(response, 'actualizar el producto');

    final updatedProduct = ProductRemoteModel.fromJson(
      _readResponseData(response, 'actualizar el producto'),
    ).toEntity();

    final syncedAttributes = await _replaceProductAttributes(
      productId: productId,
      attributes: product.attributes,
    );

    return updatedProduct.copyWith(
      createdBy: product.createdBy,
      attributes: syncedAttributes,
    );
  }

  Future<void> deleteProduct(String productId) async {
    final response = await _apiClient.delete('/api/products/$productId');
    _apiClient.validateResponse(response, 'eliminar el producto');
  }

  Future<List<ProductAttributeRemoteModel>> fetchProductAttributes({
    String? productId,
  }) async {
    final response = await _apiClient.get(
      '/api/product-attributes',
      queryParameters: productId == null || productId.trim().isEmpty
          ? null
          : {'product_id': productId},
    );

    _apiClient.validateResponse(response, 'obtener los atributos');

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('La respuesta de atributos no tiene un formato valido.');
    }

    final rawData = body['data'];
    final items = switch (rawData) {
      List<dynamic> list => list,
      Map<String, dynamic> map => [map],
      _ => const <dynamic>[],
    };

    return items
        .whereType<Map<String, dynamic>>()
        .map(ProductAttributeRemoteModel.fromJson)
        .toList();
  }

  Future<String> uploadProductImage({
    required String productId,
    required String filePath,
  }) async {
    final response = await _sendMultipartUpload(
      endpoint: '/api/products/$productId/image',
      fieldName: 'image',
      filePath: filePath,
    );
    final data = _readResponseData(response, 'subir la imagen del producto');
    return _extractUrl(data, preferKey: 'image_url');
  }

  Future<List<StoredFile>> fetchProductImageFiles() async {
    final response = await _apiClient.get('/api/files/product-images');
    return _readStoredFiles(response, 'obtener las imagenes de productos');
  }

  Future<List<StoredFile>> fetchTechnicalSheetFiles() async {
    final response = await _apiClient.get('/api/files/technical-sheets');
    return _readStoredFiles(response, 'obtener las fichas tecnicas');
  }

  Future<String> uploadGenericProductImage(String filePath) async {
    final response = await _sendMultipartUpload(
      endpoint: '/api/files/product-images/upload',
      fieldName: 'image',
      filePath: filePath,
    );
    return _readFileUrl(
      response,
      'subir la imagen del producto',
      preferKey: 'publicUrl',
    );
  }

  Future<String> uploadGenericTechnicalSheet(String filePath) async {
    final response = await _sendMultipartUpload(
      endpoint: '/api/files/technical-sheets/upload',
      fieldName: 'technical_sheet',
      filePath: filePath,
    );
    return _readFileUrl(
      response,
      'subir la ficha tecnica',
      preferKey: 'publicUrl',
    );
  }

  Future<void> deleteGenericProductImage(String url) async {
    final response = await _apiClient.delete(
      '/api/files/product-images',
      body: {'url': url},
    );
    _apiClient.validateResponse(response, 'eliminar la imagen del servidor');
  }

  Future<void> deleteGenericTechnicalSheet(String url) async {
    final response = await _apiClient.delete(
      '/api/files/technical-sheets',
      body: {'url': url},
    );
    _apiClient.validateResponse(
      response,
      'eliminar la ficha tecnica del servidor',
    );
  }

  Future<String> uploadTechnicalSheet({
    required String productId,
    required String filePath,
  }) async {
    final response = await _sendMultipartUpload(
      endpoint: '/api/products/$productId/technical-sheet',
      fieldName: 'technical_sheet',
      filePath: filePath,
    );
    final data = _readResponseData(
      response,
      'subir la ficha tecnica del producto',
    );

    return _extractUrl(data, preferKey: 'technical_sheet_url');
  }

  Future<List<ProductAttribute>> _replaceProductAttributes({
    required String productId,
    required List<ProductAttribute> attributes,
  }) async {
    final currentAttributes = await fetchProductAttributes(
      productId: productId,
    );

    for (final attribute in currentAttributes) {
      await _deleteProductAttribute(attribute.id);
    }

    final createdAttributes = <ProductAttribute>[];
    for (var index = 0; index < attributes.length; index++) {
      createdAttributes.add(
        await _createProductAttribute(
          productId: productId,
          attribute: attributes[index],
          sortOrder: index + 1,
        ),
      );
    }

    return createdAttributes;
  }

  Future<ProductAttribute> _createProductAttribute({
    required String productId,
    required ProductAttribute attribute,
    required int sortOrder,
  }) async {
    final response = await _apiClient.post(
      '/api/product-attributes',
      body: {
        'product_id': productId,
        'attribute_name': attribute.name,
        'attribute_value': attribute.value,
        'sort_order': sortOrder,
      },
    );

    _apiClient.validateResponse(response, 'crear el atributo del producto');

    return ProductAttributeRemoteModel.fromJson(
      _readResponseData(response, 'crear el atributo del producto'),
    ).toEntity();
  }

  Future<void> _deleteProductAttribute(String attributeId) async {
    final response = await _apiClient.delete(
      '/api/product-attributes/$attributeId',
    );
    _apiClient.validateResponse(response, 'eliminar un atributo del producto');
  }

  Map<String, dynamic> _readResponseData(
    http.Response response,
    String action,
  ) => ApiResponseReader.readResponseData(response, action);

  Future<http.Response> _sendMultipartUpload({
    required String endpoint,
    required String fieldName,
    required String filePath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _apiClient.resolveUri(endpoint),
    )..files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    return _apiClient.sendMultipart(request);
  }

  List<StoredFile> _readStoredFiles(http.Response response, String action) {
    _apiClient.validateResponse(response, action);
    final items = ApiResponseReader.readDataList(response, action);

    return items.map(_mapStoredFile).whereType<StoredFile>().toList();
  }

  StoredFile? _mapStoredFile(dynamic item) {
    if (item is String) {
      final url = item.trim();
      if (url.isEmpty) return null;
      return StoredFile(url: url, label: _buildFileLabel(url));
    }

    if (item is! Map<String, dynamic>) {
      return null;
    }

    final url = _extractUrl(item);
    if (url.isEmpty) {
      return null;
    }

    final label = _extractLabel(item, fallbackUrl: url);
    return StoredFile(url: url, label: label);
  }

  String _readFileUrl(
    http.Response response,
    String action, {
    String? preferKey,
  }) {
    _apiClient.validateResponse(response, action);

    // Intenta extraer el campo 'data' (por si el servidor responde { "data": { "url": "..." } })
    final jsonResponse = jsonDecode(response.body);
    final data =
        jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('data')
        ? jsonResponse['data']
        : jsonResponse;

    if (data is String) {
      final url = data.trim();
      if (url.isNotEmpty) return url;
    }

    if (data is Map<String, dynamic>) {
      final url = _extractUrl(data, preferKey: preferKey);
      if (url.isNotEmpty) {
        return url;
      }
    }

    throw Exception('La respuesta del servidor no incluye una URL valida.');
  }

  String _extractUrl(Map<String, dynamic> json, {String? preferKey}) {
    final keys = <String>[
      ...?preferKey != null ? [preferKey] : null,
      'publicUrl',
      'url',
      'file_url',
      'image_url',
      'technical_sheet_url',
      'path',
      'file',
    ];

    for (final key in keys) {
      final value = json[key]?.toString().replaceAll('`', '').trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  String _extractLabel(
    Map<String, dynamic> json, {
    required String fallbackUrl,
  }) {
    const keys = ['name', 'filename', 'file_name', 'original_name', 'title'];

    for (final key in keys) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }

    return _buildFileLabel(fallbackUrl);
  }

  String _buildFileLabel(String url) {
    final sanitizedUrl = url.split('?').first;
    final segments = sanitizedUrl.split('/');
    return segments.isEmpty ? url : segments.last;
  }
}
