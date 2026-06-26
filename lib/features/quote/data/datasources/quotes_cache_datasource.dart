import 'dart:convert';

import '../../../../../core/storage/cache_client.dart';
import '../../domain/entities/quote.dart';

class QuotesCacheDataSource {
  static const _quotesKey = 'quotes';
  final CacheClient _cache = const CacheClient();

  Future<List<Quote>> loadQuotes() async {
    final rawQuotes = await _cache.getStringList(_quotesKey);

    if (rawQuotes == null || rawQuotes.isEmpty) {
      return [];
    }

    final quotes = <Quote>[];

    for (final item in rawQuotes) {
      try {
        quotes.add(Quote.fromJson(jsonDecode(item) as Map<String, dynamic>));
      } on FormatException {
        // Ignore malformed cached entries so one bad record does not block the list.
      } on TypeError {
        // Ignore malformed cached entries so one bad record does not block the list.
      }
    }

    return quotes;
  }

  Future<void> saveQuotes(List<Quote> quotes) async {
    final rawQuotes = quotes
        .map((quote) => jsonEncode(quote.toJson()))
        .toList();

    await _cache.setStringList(_quotesKey, rawQuotes);
  }
}
