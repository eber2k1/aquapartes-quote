class ReportSummary {
  const ReportSummary({
    required this.totalQuotes,
    required this.totalAmount,
    required this.totalProducts,
    required this.totalCustomers,
  });

  final int totalQuotes;
  final double totalAmount;
  final int totalProducts;
  final int totalCustomers;
}

class ReportQuoteStatus {
  const ReportQuoteStatus({
    required this.status,
    required this.count,
    required this.amount,
  });

  final String status;
  final int count;
  final double amount;
}

class ReportTopProduct {
  const ReportTopProduct({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.amount,
  });

  final String productId;
  final String productName;
  final int quantity;
  final double amount;
}

class ReportMonthlyQuote {
  const ReportMonthlyQuote({
    required this.period,
    required this.totalQuotes,
  });

  final String period;
  final int totalQuotes;
}

class ReportMonthlySale {
  const ReportMonthlySale({
    required this.period,
    required this.totalAmount,
    required this.totalQuotes,
  });

  final String period;
  final double totalAmount;
  final int totalQuotes;
}
