import 'data/datasources/quotes_cache_datasource.dart';
import 'data/datasources/remote/quotes_remote_datasource.dart';
import 'data/repositories/quotes_repository_impl.dart';
import 'domain/repositories/quotes_repository.dart';

final QuotesRepository _quotesRepository = QuotesRepositoryImpl(
  remoteDataSource: QuotesRemoteDataSource(),
  cacheDataSource: QuotesCacheDataSource(),
);

QuotesRepository getQuotesRepository() => _quotesRepository;
