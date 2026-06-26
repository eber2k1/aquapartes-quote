import 'package:flutter/material.dart';

import '../../../../core/formatters/app_formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/report_models.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../reports_module.dart';
import '../widgets/report_charts.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportsRepository _repository = getReportsRepository();

  bool _isLoading = false;
  String? _errorMessage;

  ReportSummary? _summary;
  List<ReportQuoteStatus>? _quotesByStatus;
  List<ReportTopProduct>? _topProducts;
  List<ReportMonthlySale>? _salesByMonth;

  DateTime? _fromDate;
  DateTime? _toDate;
  String _dateFilterLabel = 'Todos los tiempos';

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final summary = await _repository.getSummary(
        from: _fromDate,
        to: _toDate,
      );
      final quotesByStatus = await _repository.getQuotesByStatus(
        from: _fromDate,
        to: _toDate,
      );
      final topProducts = await _repository.getTopProducts(
        from: _fromDate,
        to: _toDate,
        limit: 10,
      );
      final salesByMonth = await _repository.getSalesByMonth(
        from: _fromDate,
        to: _toDate,
      );

      if (mounted) {
        setState(() {
          _summary = summary;
          _quotesByStatus = quotesByStatus;
          _topProducts = topProducts;
          _salesByMonth = salesByMonth;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDateFilterOptions() {
    final now = DateTime.now();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Todos los tiempos'),
                onTap: () {
                  Navigator.pop(context);
                  _applyDateFilter(null, null, 'Todos los tiempos');
                },
              ),
              ListTile(
                title: const Text('Este mes'),
                onTap: () {
                  Navigator.pop(context);
                  final firstDay = DateTime(now.year, now.month, 1);
                  _applyDateFilter(firstDay, now, 'Este mes');
                },
              ),
              ListTile(
                title: const Text('Mes anterior'),
                onTap: () {
                  Navigator.pop(context);
                  final firstDayPrev = DateTime(now.year, now.month - 1, 1);
                  final lastDayPrev = DateTime(now.year, now.month, 0);
                  _applyDateFilter(firstDayPrev, lastDayPrev, 'Mes anterior');
                },
              ),
              ListTile(
                title: const Text('Este año'),
                onTap: () {
                  Navigator.pop(context);
                  final firstDay = DateTime(now.year, 1, 1);
                  _applyDateFilter(firstDay, now, 'Este año');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyDateFilter(DateTime? from, DateTime? to, String label) {
    setState(() {
      _fromDate = from;
      _toDate = to;
      _dateFilterLabel = label;
    });
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 16.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _showDateFilterOptions,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(_dateFilterLabel),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(theme)),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'No se pudieron cargar los informes',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: _loadReports,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_summary != null) _buildSummarySection(theme),
          const SizedBox(height: 24),
          if (_salesByMonth != null && _salesByMonth!.isNotEmpty)
            _buildSalesByMonthSection(theme),
          const SizedBox(height: 24),
          if (_quotesByStatus != null && _quotesByStatus!.isNotEmpty)
            _buildQuotesByStatusSection(theme),
          const SizedBox(height: 24),
          if (_topProducts != null && _topProducts!.isNotEmpty)
            _buildTopProductsSection(theme),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Resumen General', Icons.dashboard_outlined),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.8,
          children: [
            _SummaryCard(
              title: 'Total Cotizaciones',
              value: _summary!.totalQuotes.toString(),
              icon: Icons.request_quote_outlined,
              color: Colors.blue,
            ),
            _SummaryCard(
              title: 'Monto Total',
              value: AppFormatters.formatUsd(_summary!.totalAmount),
              icon: Icons.monetization_on_outlined,
              color: Colors.green,
            ),
            _SummaryCard(
              title: 'Clientes',
              value: _summary!.totalCustomers.toString(),
              icon: Icons.people_outline,
              color: Colors.orange,
            ),
            _SummaryCard(
              title: 'Productos',
              value: _summary!.totalProducts.toString(),
              icon: Icons.inventory_2_outlined,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalesByMonthSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          theme,
          'Tendencia de Ventas',
          Icons.trending_up_rounded,
        ),
        AppCard(
          padding: const EdgeInsets.all(16.0),
          child: MonthlySalesLineChart(data: _salesByMonth!),
        ),
      ],
    );
  }

  Widget _buildQuotesByStatusSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          theme,
          'Cotizaciones por Estado',
          Icons.pie_chart_outline_rounded,
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: QuotesByStatusPieChart(data: _quotesByStatus!),
        ),
      ],
    );
  }

  Widget _buildTopProductsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          theme,
          'Productos mas cotizados',
          Icons.bar_chart_rounded,
        ),
        AppCard(
          padding: const EdgeInsets.only(
            top: 24,
            bottom: 8,
            left: 16,
            right: 16,
          ),
          child: TopProductsBarChart(data: _topProducts!),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(30),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
