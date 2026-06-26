import '../../domain/entities/report_models.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/remote/reports_remote_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl({required this.remoteDataSource});

  final ReportsRemoteDataSource remoteDataSource;

  @override
  Future<ReportSummary> getSummary({DateTime? from, DateTime? to}) {
    return remoteDataSource.fetchSummary(
      from: _formatDate(from),
      to: _formatDate(to),
    );
  }

  @override
  Future<List<ReportQuoteStatus>> getQuotesByStatus({
    DateTime? from,
    DateTime? to,
  }) {
    return remoteDataSource.fetchQuotesByStatus(
      from: _formatDate(from),
      to: _formatDate(to),
    );
  }

  @override
  Future<List<ReportTopProduct>> getTopProducts({
    DateTime? from,
    DateTime? to,
    int? limit,
  }) {
    return remoteDataSource.fetchTopProducts(
      from: _formatDate(from),
      to: _formatDate(to),
      limit: limit,
    );
  }

  @override
  Future<List<ReportMonthlyQuote>> getQuotesByMonth({
    DateTime? from,
    DateTime? to,
  }) {
    return remoteDataSource.fetchQuotesByMonth(
      from: _formatDate(from),
      to: _formatDate(to),
    );
  }

  @override
  Future<List<ReportMonthlySale>> getSalesByMonth({
    DateTime? from,
    DateTime? to,
  }) {
    return remoteDataSource.fetchSalesByMonth(
      from: _formatDate(from),
      to: _formatDate(to),
    );
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
