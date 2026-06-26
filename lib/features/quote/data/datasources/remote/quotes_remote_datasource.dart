import 'package:http/http.dart' as http;

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response_reader.dart';
import '../../../domain/entities/quote.dart';
import '../../models/quote_remote_item_model.dart';
import '../../models/quote_remote_model.dart';

class QuotesRemoteDataSource {
  QuotesRemoteDataSource({ApiClient? apiClient})
    : _apiUserId = const String.fromEnvironment('API_USER_ID'),
      _quotePdfFieldName = const String.fromEnvironment(
        'API_QUOTE_PDF_FIELD_NAME',
        defaultValue: 'quote_pdf',
      ),
      _apiClient = apiClient ?? ApiClient();

  final String _apiUserId;
  final String _quotePdfFieldName;
  final ApiClient _apiClient;

  Future<List<Quote>> fetchQuotes({String? customerId, String? status}) async {
    final queryParams = <String, dynamic>{};
    if (customerId != null && customerId.isNotEmpty) {
      queryParams['customer_id'] = customerId;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      '/api/quotes',
      queryParameters: queryParams,
    );

    _apiClient.validateResponse(response, 'cargar las cotizaciones');

    final items = ApiResponseReader.readDataItems(response);

    return items
        .whereType<Map<String, dynamic>>()
        .map(QuoteRemoteModel.fromJson)
        .where((quote) => quote.deletedAt == null)
        .map((quote) => quote.toEntity())
        .toList();
  }

  Future<Quote> fetchQuoteById(String quoteId) async {
    final response = await _apiClient.get('/api/quotes/$quoteId');

    _apiClient.validateResponse(response, 'obtener la cotizacion');

    final data = ApiResponseReader.readResponseData(
      response,
      'obtener la cotizacion',
      flexible: true,
    );

    return QuoteRemoteModel.fromJson(data).toEntity();
  }

  Future<Quote> createQuote(Quote quote) async {
    final customerId = quote.customerId?.trim() ?? '';
    if (customerId.isEmpty) {
      throw Exception(
        'La cotizacion necesita un cliente sincronizado con la API.',
      );
    }

    final createdBy = quote.createdBy.trim().isNotEmpty
        ? quote.createdBy.trim()
        : _apiUserId.trim();
    if (createdBy.isEmpty) {
      throw Exception(
        'Falta configurar API_USER_ID para crear cotizaciones en el backend.',
      );
    }

    final remoteModel = _toRemoteModel(quote);

    final response = await _apiClient.post(
      '/api/quotes',
      body: remoteModel.toCreatePayload(createdBy: createdBy),
    );

    _apiClient.validateResponse(response, 'crear la cotizacion');

    final data = ApiResponseReader.readResponseData(
      response,
      'crear la cotizacion',
      flexible: true,
    );

    return QuoteRemoteModel.fromJson(data).toEntity();
  }

  Future<Quote> updateQuote(Quote quote) async {
    final quoteId = quote.id?.trim() ?? '';
    if (quoteId.isEmpty) {
      throw Exception('No se puede actualizar una cotizacion sin id remoto.');
    }

    final customerId = quote.customerId?.trim() ?? '';
    if (customerId.isEmpty) {
      throw Exception(
        'La cotizacion necesita un cliente sincronizado con la API.',
      );
    }

    final remoteModel = _toRemoteModel(quote);

    final response = await _apiClient.put(
      '/api/quotes/$quoteId',
      body: remoteModel.toUpdatePayload(),
    );

    _apiClient.validateResponse(response, 'actualizar la cotizacion');

    final data = ApiResponseReader.readResponseData(
      response,
      'actualizar la cotizacion',
      flexible: true,
    );

    return QuoteRemoteModel.fromJson(data).toEntity();
  }

  Future<void> deleteQuote(String quoteId) async {
    if (quoteId.isEmpty) {
      throw Exception('Cannot delete a quote without an ID.');
    }

    final response = await _apiClient.delete('/api/quotes/$quoteId');

    _apiClient.validateResponse(response, 'eliminar la cotizacion');
  }

  Future<Quote> uploadQuotePdf({
    required String quoteId,
    required List<int> bytes,
    required String fileName,
  }) async {
    if (quoteId.isEmpty) {
      throw Exception('Cannot upload PDF for a quote without an ID.');
    }

    final uri = _apiClient.resolveUri('/api/quotes/$quoteId/pdf');
    final request = http.MultipartRequest('POST', uri);

    final multipartFile = http.MultipartFile.fromBytes(
      _quotePdfFieldName,
      bytes,
      filename: fileName,
    );

    request.files.add(multipartFile);

    final response = await _apiClient.sendMultipart(request);

    _apiClient.validateResponse(response, 'subir el PDF de la cotizacion');

    return _readUploadedQuote(response);
  }

  QuoteRemoteModel _toRemoteModel(Quote quote) {
    final remoteItems = <QuoteRemoteItemModel>[];

    for (var index = 0; index < quote.items.length; index++) {
      final item = quote.items[index];
      final productId = item.productId?.trim() ?? '';
      if (productId.isEmpty) {
        throw Exception(
          'Cada item necesita un producto sincronizado con la API.',
        );
      }

      remoteItems.add(
        QuoteRemoteItemModel(
          productId: productId,
          itemOrder: item.itemOrder ?? index + 1,
          productNameSnapshot: item.productName,
          productCategorySnapshot: item.productCategory,
          unitPrice: item.unitPrice,
          quantity: item.quantity,
        ),
      );
    }

    return QuoteRemoteModel(
      id: quote.id ?? '',
      quoteNumber: quote.quoteNumber,
      customerId: quote.customerId?.trim() ?? '',
      customerName: quote.customerName,
      customerCompany: quote.customerCompany,
      customerPhone: quote.customerPhone,
      createdBy: quote.createdBy,
      createdByUserName: quote.createdByUserName,
      issueDate: quote.issueDate,
      taxPercent: quote.taxPercent,
      currency: quote.currency,
      status: quote.status,
      pdfFileUrl: quote.pdfFileUrl,
      pdfFileName: quote.pdfFileName,
      createdAt: quote.createdAt,
      updatedAt: quote.updatedAt,
      deletedAt: quote.deletedAt,
      items: remoteItems,
    );
  }

  Quote _readUploadedQuote(http.Response response) {
    final data = ApiResponseReader.readResponseData(
      response,
      'subir el PDF de la cotizacion',
      flexible: true,
    );

    if (data.containsKey('quote') && data['quote'] is Map<String, dynamic>) {
      return QuoteRemoteModel.fromJson(
        data['quote'] as Map<String, dynamic>,
      ).toEntity();
    }

    final quoteMap = _buildQuoteFromPdfPayload(data);
    return QuoteRemoteModel.fromJson(quoteMap).toEntity();
  }

  Map<String, dynamic> _buildQuoteFromPdfPayload(Map<String, dynamic> data) {
    return {
      'id': data['quote_id'] ?? data['id'],
      'quote_number': data['quote_number'],
      'customer_id': data['customer_id'],
      'customer_name': data['customer_name'],
      'customer_company': data['customer_company'],
      'customer_phone': data['customer_phone'],
      'created_by': data['created_by'],
      'issue_date': data['issue_date'],
      'tax_percent': data['tax_percent'],
      'currency': data['currency'],
      'status': data['status'],
      'pdf_file_url': data['pdf_file_url'] ?? data['url'] ?? data['file_url'],
      'pdf_file_name':
          data['pdf_file_name'] ?? data['file_name'] ?? data['filename'],
      'created_at': data['created_at'],
      'updated_at': data['updated_at'],
      'deleted_at': data['deleted_at'],
      'items': data['items'],
    };
  }
}
