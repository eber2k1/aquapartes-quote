import 'dart:typed_data';

import '../../../../core/models/repository_load_result.dart';
import '../entities/quote.dart';

abstract class QuotesRepository {
  Future<RepositoryLoadResult<List<Quote>>> loadQuotes({
    String? customerId,
    String? status,
  });
  Future<List<Quote>> loadCachedQuotes();
  Future<void> saveCachedQuotes(List<Quote> quotes);
  Future<Quote> createQuote(Quote quote);
  Future<Quote> updateQuote(Quote quote);
  Future<void> deleteQuote(String quoteId);
  Future<Quote> uploadQuotePdf({
    required String quoteId,
    required Uint8List bytes,
    required String fileName,
  });
}
