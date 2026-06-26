class AppFormatters {
  const AppFormatters._();

  static String formatUsd(double value) {
    return 'US \$${value.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  static String formatQuoteNumber(int? quoteNumber, DateTime referenceDate) {
    final number = (quoteNumber ?? 0).toString().padLeft(4, '0');
    final yearSuffix = (referenceDate.year % 100).toString().padLeft(2, '0');
    return '$number-$yearSuffix';
  }
}
