import '../../../catalog/domain/entities/product.dart';
import '../../domain/entities/quote.dart';

String buildQuoteCode(DateTime date) {
  final year = date.year.toString().substring(2);
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '$day$month-$year';
}

String formatItemNumber(int value) {
  return value.toString().padLeft(2, '0');
}

String buildReference(Quote quote) {
  if (quote.items.isEmpty) {
    return '-';
  }

  if (quote.items.length == 1) {
    return quote.items.first.productCategory.isEmpty
        ? quote.items.first.productName
        : quote.items.first.productCategory;
  }

  return 'Varios productos';
}

String formatLongDate(DateTime date) {
  const months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  return '${date.day} de ${months[date.month - 1]} del ${date.year}';
}

Product? findMatchingProduct(List<Product> products, QuoteItem item) {
  for (final product in products) {
    if (product.name == item.productName &&
        product.category == item.productCategory &&
        product.basePrice == item.unitPrice) {
      return product;
    }
  }

  return null;
}

String productValue(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '-';
  }

  return value;
}

String formatCurrency(double value) {
  return 'US \$${value.toStringAsFixed(2)}';
}
