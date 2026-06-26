import '../../domain/entities/quote.dart';

class QuoteFormResult {
  const QuoteFormResult._({this.quote, this.deleted = false});

  const QuoteFormResult.saved(Quote quote) : this._(quote: quote);

  const QuoteFormResult.deleted() : this._(deleted: true);

  final Quote? quote;
  final bool deleted;
}
