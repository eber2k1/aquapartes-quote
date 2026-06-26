import '../entities/report_models.dart';

abstract class ReportsRepository {
  Future<ReportSummary> getSummary({DateTime? from, DateTime? to});

  Future<List<ReportQuoteStatus>> getQuotesByStatus({
    DateTime? from,
    DateTime? to,
  });

  Future<List<ReportTopProduct>> getTopProducts({
    DateTime? from,
    DateTime? to,
    int? limit,
  });

  Future<List<ReportMonthlyQuote>> getQuotesByMonth({
    DateTime? from,
    DateTime? to,
  });

  Future<List<ReportMonthlySale>> getSalesByMonth({
    DateTime? from,
    DateTime? to,
  });
}
