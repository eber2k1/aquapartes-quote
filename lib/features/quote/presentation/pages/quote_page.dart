import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../../core/formatters/app_formatters.dart';
import '../../../../core/services/app_notifications.dart';
import '../../../../core/widgets/app_compact_action_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../auth/auth_module.dart';
import '../../../customers/customers_module.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/quotes_repository.dart';
import '../../quote_module.dart';
import '../../services/pdf/pdf_service.dart';
import '../helpers/quote_action_coordinator.dart';
import '../models/quote_form_result.dart';
import 'quote_form_page.dart';
import 'quote_pdf_preview_page.dart';

class QuotePage extends StatefulWidget {
  const QuotePage({super.key});

  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  final QuotesRepository _repository = getQuotesRepository();
  final List<Quote> _quotes = [];
  final TextEditingController _searchController = TextEditingController();
  late final QuoteActionCoordinator _actionCoordinator = QuoteActionCoordinator(
    repository: _repository,
    pdfService: PdfService(),
    customersRepository: getCustomersRepository(),
  );
  bool _isLoading = true;
  bool _isProcessingQuote = false;
  bool _isAdmin = false;
  String _searchQuery = '';

  List<Quote> get _visibleQuotes {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _quotes;
    }

    return _quotes.where((quote) {
      final matchesCustomer = quote.customerName.toLowerCase().contains(query);
      final matchesCompany = quote.customerCompany.toLowerCase().contains(
        query,
      );
      final matchesProducts = quote.items.any(
        (item) => item.productName.toLowerCase().contains(query),
      );

      return matchesCustomer || matchesCompany || matchesProducts;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQuotes() async {
    final session = await getAuthRepository().loadSession();
    final normalizedQuotes = await _actionCoordinator.loadQuotes();

    if (!mounted) return;

    setState(() {
      _isAdmin = session?.user.role == 'admin';
      _quotes
        ..clear()
        ..addAll(normalizedQuotes);
      _isLoading = false;
    });
  }

  String _buildCustomerInitials(Quote quote) {
    final source = quote.customerName.trim().isNotEmpty
        ? quote.customerName.trim()
        : quote.customerCompany.trim();
    final parts = source.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    final initials = parts.take(2).map((part) => part[0].toUpperCase()).join();

    return initials.isEmpty ? 'C' : initials;
  }

  String _buildPdfChipLabel(Quote quote) {
    final rawLabel = (quote.pdfFileName?.trim().isNotEmpty ?? false)
        ? quote.pdfFileName!.trim()
        : (quote.pdfFileUrl?.trim() ?? '');

    if (rawLabel.isEmpty) {
      return 'PDF sincronizado';
    }

    final sanitized = rawLabel.replaceAll('`', '').trim();
    final withoutQuery = sanitized.split('?').first;
    final basename = withoutQuery.contains('/')
        ? withoutQuery.split('/').last
        : withoutQuery;
    final label = basename.isEmpty ? 'PDF sincronizado' : basename;

    if (label.length <= 36) {
      return label;
    }

    return '${label.substring(0, 33)}...';
  }

  Widget _buildQuoteCard(Quote quote, int quoteIndex) {
    final theme = Theme.of(context);
    final companyName = quote.customerCompany.trim();
    final hasCompanyName =
        companyName.isNotEmpty &&
        companyName.toLowerCase() != quote.customerName.trim().toLowerCase();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(128),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openQuotePage(initialQuote: quote, index: quoteIndex),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _buildCustomerInitials(quote),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quote.customerName.trim().isNotEmpty
                                ? quote.customerName
                                : (companyName.isNotEmpty
                                      ? companyName
                                      : 'Cliente registrado'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (hasCompanyName) ...[
                            const SizedBox(height: 4),
                            Text(
                              companyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withAlpha(128),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppFormatters.formatUsd(quote.total),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuoteMetaChip(
                    icon: Icons.receipt_long_outlined,
                    label:
                        'Cotización ${AppFormatters.formatQuoteNumber(quote.quoteNumber, quote.createdAt)}',
                  ),
                  _QuoteMetaChip(
                    icon: Icons.calendar_today_outlined,
                    label: AppFormatters.formatDate(quote.createdAt),
                  ),
                  if ((quote.pdfFileName?.trim().isNotEmpty ?? false) ||
                      (quote.pdfFileUrl?.trim().isNotEmpty ?? false))
                    _QuoteMetaChip(
                      icon: Icons.cloud_done_outlined,
                      label: _buildPdfChipLabel(quote),
                    ),
                  if (_isAdmin)
                    _QuoteMetaChip(
                      icon: Icons.person_outline,
                      label:
                          'Por: ${(quote.createdByUserName != null && quote.createdByUserName!.isNotEmpty) ? quote.createdByUserName! : 'Admin'}',
                      color: theme.colorScheme.tertiaryContainer,
                      textColor: theme.colorScheme.onTertiaryContainer,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => _openQuotePdf(quote),
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: const Text('PDF'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => _shareQuotePdf(quote),
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Compartir'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openQuotePage({Quote? initialQuote, int? index}) async {
    final result = await Navigator.of(context).push<QuoteFormResult>(
      MaterialPageRoute(
        builder: (_) => QuoteFormPage(initialQuote: initialQuote),
      ),
    );

    if (result == null || !mounted) return;

    try {
      setState(() {
        _isProcessingQuote = true;
      });

      final updatedQuotes = await _actionCoordinator.applyResult(
        currentQuotes: _quotes,
        result: result,
        initialQuote: initialQuote,
        index: index,
      );

      if (!mounted) return;

      setState(() {
        _quotes
          ..clear()
          ..addAll(updatedQuotes);
        _isProcessingQuote = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _isProcessingQuote = false;
        });
      }
      AppNotifications.showDelete(_actionCoordinator.readErrorMessage(error));
    }
  }

  Future<void> _openQuotePdf(Quote quote) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuotePdfPreviewPage(
          quote: quote,
          fileName: _actionCoordinator.buildQuoteFileName(quote),
        ),
      ),
    );
  }

  Future<void> _shareQuotePdf(Quote quote) async {
    final pdfBytes = await _actionCoordinator.buildQuotePdf(quote);

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: _actionCoordinator.buildQuoteFileName(quote),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSearchField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                hintText: 'Buscar cliente, empresa o producto',
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadQuotes,
                        child: _quotes.isEmpty
                            ? SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: const AppEmptyState(
                                    message:
                                        'Todavia no hay cotizaciones guardadas.',
                                  ),
                                ),
                              )
                            : _visibleQuotes.isEmpty
                            ? SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: const Center(
                                    child: Text(
                                      'No se encontraron cotizaciones.',
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: _visibleQuotes.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final quote = _visibleQuotes[index];
                                  final quoteIndex = _quotes.indexOf(quote);

                                  return _buildQuoteCard(quote, quoteIndex);
                                },
                              ),
                      ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: AppCompactActionButton(
                  onPressed: _openQuotePage,
                  icon: Icons.note_add_outlined,
                  label: 'Nueva cotizacion',
                ),
              ),
            ],
          ),
        ),
        if (_isProcessingQuote)
          Positioned.fill(
            child: ColoredBox(
              color: theme.colorScheme.scrim.withValues(alpha: 0.10),
              child: Center(
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.75,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.auto_awesome_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Generando cotizacion',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Estamos guardando los datos y preparando el PDF.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          backgroundColor: theme
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Esto puede tardar unos segundos.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuoteMetaChip extends StatelessWidget {
  const _QuoteMetaChip({
    required this.icon,
    required this.label,
    this.color,
    this.textColor,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor =
        color ??
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final fgColor = textColor ?? theme.colorScheme.onSurfaceVariant;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 120,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fgColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(color: fgColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
