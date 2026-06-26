import 'package:flutter/material.dart';

import '../../../../core/services/app_notifications.dart';
import '../../../../core/widgets/app_compact_action_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_option_picker_sheet.dart';
import '../../../../core/widgets/app_option_selector.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../auth/auth_module.dart';
import '../../customers_module.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customers_repository.dart';
import '../helpers/customer_action_coordinator.dart';
import '../models/customer_display_options.dart';
import '../models/customer_form_result.dart';
import 'customer_detail_page.dart';
import 'customer_form_page.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final CustomersRepository _repository = getCustomersRepository();
  final List<Customer> _customers = [];
  final _searchController = TextEditingController();
  late final CustomerActionCoordinator _actionCoordinator =
      CustomerActionCoordinator(repository: _repository);
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isAdmin = false;
  CustomerSortMode _sortMode = CustomerSortMode.nameAsc;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    final session = await getAuthRepository().loadSession();
    final customers = await _actionCoordinator.loadCustomers();

    if (!mounted) return;

    setState(() {
      _isAdmin = session?.user.role == 'admin';
      _customers
        ..clear()
        ..addAll(customers);
      _isLoading = false;
    });
  }

  Future<void> _openCustomerPage({
    Customer? initialCustomer,
    int? index,
  }) async {
    final result = await Navigator.of(context).push<CustomerFormResult>(
      MaterialPageRoute(
        builder: (_) => CustomerFormPage(initialCustomer: initialCustomer),
      ),
    );

    await _handleCustomerResult(
      result: result,
      initialCustomer: initialCustomer,
      index: index,
    );
  }

  Future<void> _openCustomerDetailPage({
    required Customer customer,
    required int index,
  }) async {
    final result = await Navigator.of(context).push<CustomerFormResult>(
      MaterialPageRoute(builder: (_) => CustomerDetailPage(customer: customer)),
    );

    await _handleCustomerResult(
      result: result,
      initialCustomer: customer,
      index: index,
    );
  }

  Future<void> _handleCustomerResult({
    required CustomerFormResult? result,
    Customer? initialCustomer,
    int? index,
  }) async {
    if (result == null) return;
    if (!mounted) return;

    try {
      final updatedCustomers = await _actionCoordinator.applyResult(
        currentCustomers: _customers,
        result: result,
        initialCustomer: initialCustomer,
        index: index,
      );

      if (!mounted) return;

      setState(() {
        _customers
          ..clear()
          ..addAll(updatedCustomers);
      });
    } catch (_) {
      AppNotifications.showDelete('No se pudo guardar el cliente en la API.');
    }
  }

  Future<void> _openSortModeSelector() async {
    final selectedMode = await showModalBottomSheet<CustomerSortMode>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AppOptionPickerSheet<CustomerSortMode>(
        title: 'Ordenar clientes',
        subtitle: 'Selecciona el orden alfabetico que quieres aplicar.',
        selectedValue: _sortMode,
        options: CustomerSortMode.values
            .map(
              (mode) => AppOptionItem<CustomerSortMode>(
                value: mode,
                label: CustomerDisplayOptions.sortModeLabel(mode),
                icon: CustomerDisplayOptions.sortModeIcon(mode),
              ),
            )
            .toList(),
      ),
    );

    if (selectedMode == null || !mounted) return;

    setState(() {
      _sortMode = selectedMode;
    });
  }

  List<Customer> get _visibleCustomers {
    final query = _searchQuery.trim().toLowerCase();

    final filteredCustomers = query.isEmpty
        ? List<Customer>.from(_customers)
        : _customers.where((customer) {
            return customer.contactName.toLowerCase().contains(query) ||
                customer.companyName.toLowerCase().contains(query);
          }).toList();

    filteredCustomers.sort((a, b) {
      final primaryComparison = switch (_sortMode) {
        CustomerSortMode.nameAsc => a.contactName.toLowerCase().compareTo(
          b.contactName.toLowerCase(),
        ),
        CustomerSortMode.nameDesc => b.contactName.toLowerCase().compareTo(
          a.contactName.toLowerCase(),
        ),
      };

      if (primaryComparison != 0) {
        return primaryComparison;
      }

      return a.companyName.toLowerCase().compareTo(b.companyName.toLowerCase());
    });

    return filteredCustomers;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppSearchField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  hintText: 'Buscar cliente o razon social',
                ),
              ),
              const SizedBox(width: 12),
              AppOptionSelector(
                icon: CustomerDisplayOptions.sortModeIcon(_sortMode),
                onTap: _openSortModeSelector,
                compact: true,
                tooltip:
                    'Orden: ${CustomerDisplayOptions.sortModeLabel(_sortMode)}',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadCustomers,
                    child: _customers.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const AppEmptyState(
                                message: 'Todavia no hay clientes agregados.',
                              ),
                            ),
                          )
                        : _visibleCustomers.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const Center(
                                child: Text('No se encontraron clientes.'),
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _visibleCustomers.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final customer = _visibleCustomers[index];
                              final customerIndex = _customers.indexOf(
                                customer,
                              );

                              final initials =
                                  customer.companyName.trim().isNotEmpty
                                  ? customer.companyName.trim()[0].toUpperCase()
                                  : (customer.contactName.trim().isNotEmpty
                                        ? customer.contactName
                                              .trim()[0]
                                              .toUpperCase()
                                        : 'C');

                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: theme.colorScheme.outlineVariant
                                        .withAlpha(128),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => _openCustomerDetailPage(
                                    customer: customer,
                                    index: customerIndex,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme
                                                .primaryContainer,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            initials,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onPrimaryContainer,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                customer.contactName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              if (customer.companyName
                                                  .trim()
                                                  .isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  customer.companyName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                              ],
                                              if (_isAdmin) ...[
                                                const SizedBox(height: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme
                                                        .primaryContainer
                                                        .withAlpha(128),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.person_outline,
                                                        size: 10,
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Por: ${(customer.createdByUserName != null && customer.createdByUserName!.isNotEmpty) ? customer.createdByUserName! : 'Admin'}',
                                                        style: theme
                                                            .textTheme
                                                            .labelSmall
                                                            ?.copyWith(
                                                              color: theme
                                                                  .colorScheme
                                                                  .primary,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withAlpha(128),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: AppCompactActionButton(
              onPressed: _openCustomerPage,
              icon: Icons.person_add_alt_1,
              label: 'Anadir cliente',
            ),
          ),
        ],
      ),
    );
  }
}
