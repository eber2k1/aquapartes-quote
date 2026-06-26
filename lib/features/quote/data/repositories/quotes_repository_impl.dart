import 'dart:typed_data';

import '../../../../core/models/repository_load_result.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/quotes_repository.dart';
import '../datasources/quotes_cache_datasource.dart';
import '../datasources/remote/quotes_remote_datasource.dart';

class QuotesRepositoryImpl implements QuotesRepository {
  QuotesRepositoryImpl({
    required this._remoteDataSource,
    required this._cacheDataSource,
  });

  final QuotesRemoteDataSource _remoteDataSource;
  final QuotesCacheDataSource _cacheDataSource;

  @override
  Future<RepositoryLoadResult<List<Quote>>> loadQuotes({
    String? customerId,
    String? status,
  }) async {
    try {
      final quotes = await _remoteDataSource.fetchQuotes(
        customerId: customerId,
        status: status,
      );
      await _cacheDataSource.saveQuotes(quotes);
      return RepositoryLoadResult(data: quotes, fromCache: false);
    } catch (error) {
      final cachedQuotes = await _cacheDataSource.loadQuotes();
      return RepositoryLoadResult(
        data: cachedQuotes,
        fromCache: true,
        errorMessage: error.toString(),
      );
    }
  }

  @override
  Future<List<Quote>> loadCachedQuotes() {
    return _cacheDataSource.loadQuotes();
  }

  @override
  Future<void> saveCachedQuotes(List<Quote> quotes) {
    return _cacheDataSource.saveQuotes(quotes);
  }

  @override
  Future<Quote> createQuote(Quote quote) {
    return _remoteDataSource.createQuote(quote);
  }

  @override
  Future<Quote> updateQuote(Quote quote) {
    return _remoteDataSource.updateQuote(quote);
  }

  @override
  Future<void> deleteQuote(String quoteId) {
    return _remoteDataSource.deleteQuote(quoteId);
  }

  @override
  Future<Quote> uploadQuotePdf({
    required String quoteId,
    required Uint8List bytes,
    required String fileName,
  }) {
    return _remoteDataSource.uploadQuotePdf(
      quoteId: quoteId,
      bytes: bytes,
      fileName: fileName,
    );
  }
}
