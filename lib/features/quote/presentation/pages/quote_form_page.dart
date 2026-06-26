import 'package:flutter/material.dart';

import '../../../../core/formatters/app_formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../auth/auth_module.dart';
import '../../../catalog/catalog_module.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../../../customers/customers_module.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/domain/repositories/customers_repository.dart';
import '../../domain/entities/quote.dart';
import '../helpers/quote_form_support_helper.dart';
import '../models/quote_form_result.dart';

class QuoteFormPage extends StatefulWidget {
  const QuoteFormPage({super.key, this.initialQuote});

  final Quote? initialQuote;

  bool get isEditing => initialQuote != null;

  @override
  State<QuoteFormPage> createState() => _QuoteFormPageState();
}

class _QuoteFormPageState extends State<QuoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final CatalogRepository _catalogRepository = getCatalogRepository();
  final CustomersRepository _customersRepository = getCustomersRepository();
  final _quantityController = TextEditingController(text: '1');
  final _customerController = TextEditingController();
  final _productController = TextEditingController();
  final _customerFocusNode = FocusNode();
  final _productFocusNode = FocusNode();
  late final QuoteFormSupportHelper _formHelper = QuoteFormSupportHelper(
    catalogRepository: _catalogRepository,
    customersRepository: _customersRepository,
  );

  List<Product> _products = [];
  List<Customer> _customers = [];
  List<QuoteItem> _quoteItems = [];
  Product? _selectedProduct;
  Customer? _selectedCustomer;
  bool _isLoading = true;
  int? _editingItemIndex;

  @override
  void initState() {
    super.initState();

    final initialQuote = widget.initialQuote;
    if (initialQuote != null) {
      _quoteItems = List<QuoteItem>.from(initialQuote.items);
    }

    _quantityController.addListener(_refreshTotals);
    _loadDependencies();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _customerController.dispose();
    _productController.dispose();
    _customerFocusNode.dispose();
    _productFocusNode.dispose();
    super.dispose();
  }

  void _refreshTotals() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadDependencies() async {
    final dependencies = await _formHelper.loadDependencies(
      initialQuote: widget.initialQuote,
      initialItems: _quoteItems,
    );

    if (!mounted) return;

    setState(() {
      _customers = dependencies.customers;
      _products = dependencies.products;
      _quoteItems = dependencies.hydratedItems;
      _selectedCustomer = dependencies.selectedCustomer;
      _selectedProduct = dependencies.selectedProduct;
      _customerController.text = dependencies.customerText;
      _productController.text = dependencies.productText;
      _isLoading = false;
    });
  }

  String _customerLabel(Customer customer) {
    return _formHelper.customerLabel(customer);
  }

  String _productLabel(Product product) {
    return _formHelper.productLabel(product);
  }

  Iterable<Customer> _filterCustomers(String rawQuery) {
    return _formHelper.filterCustomers(_customers, rawQuery);
  }

  Iterable<Product> _filterProducts(String rawQuery) {
    return _formHelper.filterProducts(_products, rawQuery);
  }

  Customer? _findCustomerFromInput() {
    return _formHelper.findCustomerFromInput(
      _customers,
      _customerController.text,
    );
  }

  Product? _findProductFromInput() {
    return _formHelper.findProductFromInput(_products, _productController.text);
  }

  bool get _canSaveQuote {
    return (_selectedCustomer != null || _findCustomerFromInput() != null) &&
        _quoteItems.isNotEmpty;
  }

  Future<void> _createCustomer() async {
    final result = await _formHelper.createCustomer(
      context: context,
      currentCustomers: _customers,
    );

    if (result == null || !mounted) return;

    setState(() {
      _customers = result.items;
      _selectedCustomer = result.selectedItem;
      _customerController.text = _customerLabel(result.selectedItem);
    });
  }

  Future<void> _createProduct() async {
    final result = await _formHelper.createProduct(
      context: context,
      currentProducts: _products,
    );

    if (result == null || !mounted) return;

    setState(() {
      _products = result.items;
      _selectedProduct = result.selectedItem;
      _productController.text = _productLabel(result.selectedItem);
    });
  }

  void _saveOrUpdateItem() {
    final selectedProduct = _selectedProduct ?? _findProductFromInput();
    if (selectedProduct == null) {
      _showMessage('Selecciona un producto para agregarlo.');
      return;
    }

    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      _showMessage('Ingresa una cantidad valida.');
      return;
    }

    final item = QuoteItem(
      productId: selectedProduct.id,
      itemOrder: _editingItemIndex == null
          ? _quoteItems.length + 1
          : _editingItemIndex! + 1,
      productName: selectedProduct.name,
      productCategory: selectedProduct.category,
      unitPrice: selectedProduct.basePrice,
      quantity: quantity,
    );

    setState(() {
      _selectedProduct = selectedProduct;

      if (_editingItemIndex == null) {
        _quoteItems = [..._quoteItems, item];
      } else {
        _quoteItems = [..._quoteItems]..[_editingItemIndex!] = item;
      }

      _editingItemIndex = null;
      _quantityController.text = '1';
      _selectedProduct = null;
      _productController.clear();
    });
  }

  void _showMessage(String message) {
    _formHelper.showMessage(context, message);
  }

  void _editItem(int index) {
    final item = _quoteItems[index];
    final product = _formHelper.resolveProductForItem(item, _products);

    setState(() {
      _editingItemIndex = index;
      _selectedProduct = product;
      _quantityController.text = item.quantity.toString();
      _productController.text = product == null
          ? item.productName
          : _productLabel(product);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _quoteItems = [..._quoteItems]..removeAt(index);

      if (_editingItemIndex == index) {
        _editingItemIndex = null;
        _quantityController.text = '1';
      }
      _quoteItems = _quoteItems.asMap().entries.map((entry) {
        return entry.value.copyWith(itemOrder: entry.key + 1);
      }).toList();
    });
  }

  double get _currentSubtotal =>
      _quoteItems.fold(0.0, (sum, item) => sum + item.subtotal);

  double get _currentTaxableAmount => _currentSubtotal;

  double get _currentIgvAmount => _currentTaxableAmount * 0.18;

  double get _currentTotal => _currentTaxableAmount + _currentIgvAmount;

  Future<void> _saveQuote() async {
    if (!_formKey.currentState!.validate()) return;
    final selectedCustomer = _selectedCustomer ?? _findCustomerFromInput();
    if (selectedCustomer == null) {
      _showMessage('Selecciona un cliente para guardar la cotizacion.');
      return;
    }
    if ((selectedCustomer.id?.trim() ?? '').isEmpty) {
      _showMessage(
        'El cliente debe existir en la API para guardar la cotizacion.',
      );
      return;
    }
    if (_quoteItems.isEmpty) {
      _showMessage('Agrega al menos un producto a la cotizacion.');
      return;
    }
    if (_quoteItems.any((item) => (item.productId?.trim() ?? '').isEmpty)) {
      _showMessage(
        'Todos los items deben estar vinculados a productos existentes en la API.',
      );
      return;
    }

    final initialCreatedBy = widget.initialQuote?.createdBy.trim() ?? '';
    final session = await getAuthRepository().loadSession();
    if (!mounted) return;

    final quote = Quote(
      id: widget.initialQuote?.id,
      quoteNumber: widget.initialQuote?.quoteNumber,
      createdAt: widget.initialQuote?.createdAt ?? DateTime.now(),
      issueDate: widget.initialQuote?.issueDate ?? DateTime.now(),
      customerId: selectedCustomer.id,
      customerName: selectedCustomer.contactName,
      customerCompany: selectedCustomer.companyName,
      customerPhone: selectedCustomer.phone,
      items: _quoteItems.asMap().entries.map((entry) {
        return entry.value.copyWith(itemOrder: entry.key + 1);
      }).toList(),
      taxPercent: widget.initialQuote?.taxPercent ?? 18,
      currency: widget.initialQuote?.currency ?? 'USD',
      status: widget.initialQuote?.status ?? 'draft',
      pdfFileUrl: widget.initialQuote?.pdfFileUrl,
      createdBy: initialCreatedBy.isNotEmpty
          ? initialCreatedBy
          : (selectedCustomer.createdBy.trim().isNotEmpty
                ? selectedCustomer.createdBy
                : session?.user.id ?? ''),
      updatedAt: widget.initialQuote?.updatedAt,
      deletedAt: widget.initialQuote?.deletedAt,
    );

    Navigator.of(context).pop(QuoteFormResult.saved(quote));
  }

  Future<void> _deleteQuote() async {
    final shouldDelete = await AppConfirmationDialog.show(
      context,
      title: 'Eliminar cotizacion',
      content:
          'Esta cotizacion se eliminara permanentemente. Esta accion no se puede deshacer.',
      confirmText: 'Eliminar',
      isDestructive: true,
    );

    if (!shouldDelete || !mounted) return;

    Navigator.of(context).pop(const QuoteFormResult.deleted());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Editar cotizacion' : 'Nueva cotizacion',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Datos del cliente',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: FormField<Customer>(
                                    validator: (_) {
                                      if (_selectedCustomer == null &&
                                          _findCustomerFromInput() == null) {
                                        return 'Selecciona un cliente';
                                      }
                                      return null;
                                    },
                                    builder: (field) {
                                      return _AutocompleteSelector<Customer>(
                                        labelText: 'Cliente',
                                        controller: _customerController,
                                        focusNode: _customerFocusNode,
                                        optionsBuilder: _filterCustomers,
                                        displayStringForOption: _customerLabel,
                                        onSelected: (customer) {
                                          setState(() {
                                            _selectedCustomer = customer;
                                            _customerController.text =
                                                _customerLabel(customer);
                                          });
                                          field.didChange(customer);
                                        },
                                        onChanged: (value) {
                                          if (_selectedCustomer != null &&
                                              _customerLabel(
                                                    _selectedCustomer!,
                                                  ).trim().toLowerCase() !=
                                                  value.trim().toLowerCase()) {
                                            setState(() {
                                              _selectedCustomer = null;
                                            });
                                          }
                                          field.didChange(
                                            _findCustomerFromInput(),
                                          );
                                        },
                                        errorText: field.errorText,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton.filled(
                                  onPressed: _createCustomer,
                                  icon: const Icon(Icons.person_add_alt_1),
                                  tooltip: 'Anadir cliente',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Agregar producto',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _AutocompleteSelector<Product>(
                                    labelText: 'Producto',
                                    controller: _productController,
                                    focusNode: _productFocusNode,
                                    optionsBuilder: _filterProducts,
                                    displayStringForOption: _productLabel,
                                    onSelected: (product) {
                                      setState(() {
                                        _selectedProduct = product;
                                        _productController.text = _productLabel(
                                          product,
                                        );
                                      });
                                    },
                                    onChanged: (value) {
                                      if (_selectedProduct != null &&
                                          _productLabel(
                                                _selectedProduct!,
                                              ).trim().toLowerCase() !=
                                              value.trim().toLowerCase()) {
                                        setState(() {
                                          _selectedProduct = null;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton.filled(
                                  onPressed: _createProduct,
                                  icon: const Icon(Icons.add_box_outlined),
                                  tooltip: 'Anadir producto',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Cantidad',
                                prefixIcon: Icon(Icons.numbers_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _saveOrUpdateItem,
                              icon: Icon(
                                _editingItemIndex == null
                                    ? Icons.add_shopping_cart
                                    : Icons.save_outlined,
                              ),
                              label: Text(
                                _editingItemIndex == null
                                    ? 'Agregar producto'
                                    : 'Actualizar producto',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_quoteItems.isEmpty)
                        AppCard(
                          padding: const EdgeInsets.all(16),
                          child: const Text(
                            'Todavia no hay productos agregados a esta cotizacion.',
                          ),
                        )
                      else
                        AppCard(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: _quoteItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;

                              return ListTile(
                                title: Text(
                                  item.productName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${item.productCategory}\nCantidad: ${item.quantity}',
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppFormatters.formatUsd(item.subtotal),
                                    ),
                                    IconButton(
                                      onPressed: () => _editItem(index),
                                      icon: const Icon(Icons.edit_outlined),
                                      tooltip: 'Editar item',
                                    ),
                                    IconButton(
                                      onPressed: () => _removeItem(index),
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: 'Eliminar item',
                                      color: theme.colorScheme.error,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Resumen',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SummaryRow(
                              label: 'Subtotal',
                              value: _currentSubtotal,
                            ),
                            _SummaryRow(
                              label: 'IGV 18%',
                              value: _currentIgvAmount,
                            ),
                            const Divider(height: 24),
                            _SummaryRow(
                              label: 'Total',
                              value: _currentTotal,
                              isEmphasized: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _canSaveQuote ? _saveQuote : null,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(
                          widget.isEditing
                              ? 'Guardar cambios'
                              : 'Guardar cotizacion',
                        ),
                      ),
                      if (widget.isEditing) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _deleteQuote,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Eliminar cotizacion'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            side: BorderSide(
                              color: theme.colorScheme.error.withAlpha(128),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final double value;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final textStyle = isEmphasized
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text(AppFormatters.formatUsd(value), style: textStyle),
        ],
      ),
    );
  }
}

class _AutocompleteSelector<T extends Object> extends StatelessWidget {
  const _AutocompleteSelector({
    required this.labelText,
    required this.controller,
    required this.focusNode,
    required this.optionsBuilder,
    required this.displayStringForOption,
    required this.onSelected,
    required this.onChanged,
    this.errorText,
  });

  final String labelText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Iterable<T> Function(String query) optionsBuilder;
  final String Function(T option) displayStringForOption;
  final ValueChanged<T> onSelected;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<T>(
      textEditingController: controller,
      focusNode: focusNode,
      displayStringForOption: displayStringForOption,
      optionsBuilder: (textEditingValue) {
        return optionsBuilder(textEditingValue.text);
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, textController, textFocusNode, _) {
        return TextFormField(
          controller: textController,
          focusNode: textFocusNode,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: 'Escribe para buscar',

            errorText: errorText,
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final theme = Theme.of(context);
        final optionsList = options.toList(growable: false);

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surface,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, minWidth: 280),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: optionsList.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                itemBuilder: (context, index) {
                  final option = optionsList[index];

                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        displayStringForOption(option),
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
