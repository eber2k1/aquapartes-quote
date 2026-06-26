import 'package:flutter/material.dart';

import '../../../../core/formatters/app_formatters.dart';
import '../../../../core/widgets/app_list_tile.dart';
import '../../../quote/domain/entities/quote.dart';
import '../../../quote/domain/repositories/quotes_repository.dart';
import '../../../quote/quote_module.dart';
import '../../domain/entities/customer.dart';
import '../models/customer_form_result.dart';
import 'customer_form_page.dart';

class CustomerDetailPage extends StatefulWidget {
  const CustomerDetailPage({super.key, required this.customer});

  final Customer customer;

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final QuotesRepository _quotesRepository = getQuotesRepository();
  List<Quote> _customerQuotes = [];
  bool _isLoading = true;
  int _selectedSegment = 0;

  Customer get customer => widget.customer;

  @override
  void initState() {
    super.initState();
    _loadCustomerQuotes();
  }

  Future<void> _loadCustomerQuotes() async {
    final quotes = await _quotesRepository.loadCachedQuotes();
    final customerQuotes = quotes.where(_belongsToCustomer).toList()
      ..sort((a, b) => (b.quoteNumber ?? 0).compareTo(a.quoteNumber ?? 0));

    if (!mounted) return;

    setState(() {
      _customerQuotes = customerQuotes;
      _isLoading = false;
    });
  }

  bool _belongsToCustomer(Quote quote) {
    final customerId = customer.id?.trim() ?? '';
    final quoteCustomerId = quote.customerId?.trim() ?? '';
    if (customerId.isNotEmpty && quoteCustomerId.isNotEmpty) {
      return customerId == quoteCustomerId;
    }

    return quote.customerName.trim().toLowerCase() ==
            customer.contactName.trim().toLowerCase() &&
        quote.customerCompany.trim().toLowerCase() ==
            customer.companyName.trim().toLowerCase() &&
        quote.customerPhone.trim().toLowerCase() ==
            customer.phone.trim().toLowerCase();
  }

  Future<void> _openEditPage(BuildContext context) async {
    final result = await Navigator.of(context).push<CustomerFormResult>(
      MaterialPageRoute(
        builder: (_) => CustomerFormPage(initialCustomer: customer),
      ),
    );

    if (result == null || !context.mounted) return;

    Navigator.of(context).pop(result);
  }

  String _displayValue(String value) {
    return value.trim().isEmpty ? '-' : value.trim();
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  customer.companyName.isNotEmpty
                      ? customer.companyName[0].toUpperCase()
                      : 'C',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 3,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  color: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  onPressed: () => _openEditPage(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _displayValue(customer.contactName),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (customer.companyName.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            _displayValue(customer.companyName),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuotesSegment(ThemeData theme) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_customerQuotes.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Todavia no hay cotizaciones registradas para este cliente.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: _customerQuotes.asMap().entries.map((entry) {
            final quote = entry.value;
            final firstItem = quote.items.firstOrNull;
            final summary = firstItem == null
                ? 'Sin productos'
                : quote.items.length == 1
                ? firstItem.productName
                : '${firstItem.productName} + ${quote.items.length - 1} mas';

            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == _customerQuotes.length - 1 ? 0 : 12,
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cotización ${AppFormatters.formatQuoteNumber(quote.quoteNumber, quote.createdAt)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Creada: ${AppFormatters.formatDate(quote.createdAt)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            summary,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppFormatters.formatUsd(quote.total),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoSegment() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withAlpha(128),
            ),
          ),
          child: Column(
            children: [
              AppListTile(
                icon: Icons.business_outlined,
                title: 'Razon social',
                subtitle: _displayValue(customer.companyName),
              ),
              AppListTile(
                icon: Icons.person_outline,
                title: 'Contacto',
                subtitle: _displayValue(customer.contactName),
              ),
              AppListTile(
                icon: Icons.phone_outlined,
                title: 'Telefono',
                subtitle: _displayValue(customer.phone),
              ),
              AppListTile(
                icon: Icons.email_outlined,
                title: 'Correo',
                subtitle: _displayValue(customer.email),
              ),
              AppListTile(
                icon: Icons.location_on_outlined,
                title: 'Direccion',
                subtitle: _displayValue(customer.address),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cliente')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(theme),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment<int>(
                        value: 0,
                        label: Text('Cotizaciones'),
                        icon: Icon(Icons.receipt_long_outlined),
                      ),
                      ButtonSegment<int>(
                        value: 1,
                        label: Text('Informacion'),
                        icon: Icon(Icons.info_outline),
                      ),
                    ],
                    selected: {_selectedSegment},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) {
                      setState(() {
                        _selectedSegment = selection.first;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _selectedSegment == 0
                  ? _buildQuotesSegment(theme)
                  : _buildInfoSegment(),
            ],
          ),
        ),
      ),
    );
  }
}
