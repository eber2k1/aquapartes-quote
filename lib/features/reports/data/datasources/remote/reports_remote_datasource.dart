import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response_reader.dart';
import '../../../domain/entities/report_models.dart';

class ReportsRemoteDataSource {
  ReportsRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ReportSummary> fetchSummary({String? from, String? to}) async {
    final query = <String, dynamic>{};
    if (from != null) query['from'] = from;
    if (to != null) query['to'] = to;

    final response = await _apiClient.get(
      '/api/reports/summary',
      queryParameters: query.isEmpty ? null : query,
    );

    _apiClient.validateResponse(response, 'obtener el resumen de informes');
    final data = ApiResponseReader.readResponseData(
      response,
      'obtener el resumen de informes',
    );

    return ReportSummary(
      totalQuotes: _parseInt(
        data['total_quotes'] ?? data['totalQuotes'] ?? data['count'],
      ),
      totalAmount: _parseDouble(
        data['total_amount'] ?? data['totalAmount'] ?? data['amount'],
      ),
      totalProducts: _parseInt(
        data['total_catalog_products'] ??
            data['total_products'] ??
            data['totalProducts'],
      ),
      totalCustomers: _parseInt(
        data['total_customers'] ?? data['totalCustomers'],
      ),
    );
  }

  Future<List<ReportQuoteStatus>> fetchQuotesByStatus({
    String? from,
    String? to,
  }) async {
    final query = <String, dynamic>{};
    if (from != null) query['from'] = from;
    if (to != null) query['to'] = to;

    final response = await _apiClient.get(
      '/api/reports/quotes-by-status',
      queryParameters: query.isEmpty ? null : query,
    );

    _apiClient.validateResponse(response, 'obtener cotizaciones por estado');
    final items = ApiResponseReader.readDataList(
      response,
      'obtener cotizaciones por estado',
    );

    return items.whereType<Map<String, dynamic>>().map((json) {
      return ReportQuoteStatus(
        status: json['status']?.toString() ?? 'Desconocido',
        count: _parseInt(json['count'] ?? json['total']),
        amount: _parseDouble(json['amount'] ?? json['total_amount']),
      );
    }).toList();
  }

  Future<List<ReportTopProduct>> fetchTopProducts({
    String? from,
    String? to,
    int? limit,
  }) async {
    final query = <String, dynamic>{};
    if (from != null) query['from'] = from;
    if (to != null) query['to'] = to;
    if (limit != null) query['limit'] = limit.toString();

    final response = await _apiClient.get(
      '/api/reports/top-products',
      queryParameters: query.isEmpty ? null : query,
    );

    _apiClient.validateResponse(response, 'obtener productos principales');
    final items = ApiResponseReader.readDataList(
      response,
      'obtener productos principales',
    );

    return items.whereType<Map<String, dynamic>>().map((json) {
      return ReportTopProduct(
        productId:
            json['product_id']?.toString() ?? json['id']?.toString() ?? '',
        productName:
            json['product_name']?.toString() ??
            json['name']?.toString() ??
            'Producto sin nombre',
        quantity: _parseInt(
          json['quantity'] ?? json['count'] ?? json['total_quantity'],
        ),
        amount: _parseDouble(json['amount'] ?? json['total_amount']),
      );
    }).toList();
  }

  Future<List<ReportMonthlyQuote>> fetchQuotesByMonth({
    String? from,
    String? to,
  }) async {
    final query = <String, dynamic>{};
    if (from != null) query['from'] = from;
    if (to != null) query['to'] = to;

    final response = await _apiClient.get(
      '/api/reports/quotes-by-month',
      queryParameters: query.isEmpty ? null : query,
    );

    _apiClient.validateResponse(response, 'obtener cotizaciones por mes');
    final items = ApiResponseReader.readDataList(
      response,
      'obtener cotizaciones por mes',
    );

    return items.whereType<Map<String, dynamic>>().map((json) {
      return ReportMonthlyQuote(
        period: json['period']?.toString() ?? '',
        totalQuotes: _parseInt(json['total_quotes'] ?? json['count']),
      );
    }).toList();
  }

  Future<List<ReportMonthlySale>> fetchSalesByMonth({
    String? from,
    String? to,
  }) async {
    final query = <String, dynamic>{};
    if (from != null) query['from'] = from;
    if (to != null) query['to'] = to;

    final response = await _apiClient.get(
      '/api/reports/sales-by-month',
      queryParameters: query.isEmpty ? null : query,
    );

    _apiClient.validateResponse(response, 'obtener ventas por mes');
    final items = ApiResponseReader.readDataList(
      response,
      'obtener ventas por mes',
    );

    return items.whereType<Map<String, dynamic>>().map((json) {
      return ReportMonthlySale(
        period: json['period']?.toString() ?? '',
        totalAmount: _parseDouble(json['total_amount'] ?? json['amount']),
        totalQuotes: _parseInt(json['total_quotes'] ?? json['count']),
      );
    }).toList();
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
