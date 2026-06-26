import 'package:flutter/material.dart';

import '../../../../core/services/app_notifications.dart';
import '../../../../core/widgets/app_compact_action_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_option_picker_sheet.dart';
import '../../../auth/auth_module.dart';
import '../../catalog_module.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../helpers/catalog_product_action_coordinator.dart';
import '../helpers/catalog_products_view_helper.dart';
import '../models/catalog_display_options.dart';
import '../models/product_form_result.dart';
import '../widgets/catalog_group_section.dart';
import '../widgets/catalog_product_card.dart';
import '../widgets/catalog_toolbar.dart';
import 'product_detail_page.dart';
import 'product_form_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final CatalogRepository _repository = getCatalogRepository();
  late final CatalogProductActionCoordinator _actionCoordinator =
      CatalogProductActionCoordinator(repository: _repository);
  final List<Product> _products = [];
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isAdmin = false;
  CatalogViewMode _viewMode = CatalogViewMode.loose;
  CatalogSortMode _sortMode = CatalogSortMode.nameAsc;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final session = await getAuthRepository().loadSession();
    final result = await _repository.loadProducts();

    if (result.fromCache) {
      AppNotifications.showInfo(
        'No se pudo cargar el catalogo desde la API. Se mostraran los datos locales.',
      );
    }

    if (!mounted) return;

    setState(() {
      _isAdmin = session?.user.role == 'admin';
      _products
        ..clear()
        ..addAll(result.data);
      _isLoading = false;
    });
  }

  List<Product> get _visibleProducts {
    return CatalogProductsViewHelper.buildVisibleProducts(
      products: _products,
      searchQuery: _searchQuery,
      sortMode: _sortMode,
    );
  }

  Map<String, List<Product>> get _groupedProducts {
    return CatalogProductsViewHelper.groupProducts(
      products: _visibleProducts,
      viewMode: _viewMode,
    );
  }

  Future<void> _openViewModeSelector() async {
    final selectedMode = await showModalBottomSheet<CatalogViewMode>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AppOptionPickerSheet<CatalogViewMode>(
        title: 'Elegir vista',
        subtitle: 'Selecciona como quieres ver los productos.',
        selectedValue: _viewMode,
        options: CatalogViewMode.values
            .map(
              (mode) => AppOptionItem<CatalogViewMode>(
                value: mode,
                label: CatalogDisplayOptions.viewModeLabel(mode),
                icon: CatalogDisplayOptions.viewModeIcon(mode),
              ),
            )
            .toList(),
      ),
    );

    if (selectedMode == null || !mounted) return;

    setState(() {
      _viewMode = selectedMode;
    });
  }

  Future<void> _openSortModeSelector() async {
    final selectedMode = await showModalBottomSheet<CatalogSortMode>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AppOptionPickerSheet<CatalogSortMode>(
        title: 'Ordenar productos',
        subtitle: 'Selecciona el orden que quieres aplicar.',
        selectedValue: _sortMode,
        options: CatalogSortMode.values
            .map(
              (mode) => AppOptionItem<CatalogSortMode>(
                value: mode,
                label: CatalogDisplayOptions.sortModeLabel(mode),
                icon: CatalogDisplayOptions.sortModeIcon(mode),
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

  Widget _buildProductsList() {
    if (_viewMode == CatalogViewMode.loose) {
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _visibleProducts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = _visibleProducts[index];
          final productIndex = _products.indexOf(product);

          return CatalogProductCard(
            product: product,
            isAdmin: _isAdmin,
            onTap: () =>
                _openProductDetailPage(product: product, index: productIndex),
          );
        },
      );
    }

    final groupedEntries = _groupedProducts.entries.toList();

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: groupedEntries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final entry = groupedEntries[index];
        return CatalogGroupSection(
          title: entry.key,
          products: entry.value,
          isAdmin: _isAdmin,
          onProductTap: (product) {
            final productIndex = _products.indexOf(product);

            _openProductDetailPage(product: product, index: productIndex);
          },
        );
      },
    );
  }

  Future<void> _openProductDetailPage({
    required Product product,
    required int index,
  }) async {
    final result = await Navigator.of(context).push<ProductFormResult>(
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(
          product: product,
          existingProducts: _products,
          isAdmin: _isAdmin,
        ),
      ),
    );

    await _handleProductResult(
      result: result,
      initialProduct: product,
      index: index,
    );
  }

  Future<void> _openProductPage() async {
    final result = await Navigator.of(context).push<ProductFormResult>(
      MaterialPageRoute(
        builder: (_) => ProductFormPage(existingProducts: _products),
      ),
    );

    await _handleProductResult(result: result);
  }

  Future<void> _handleProductResult({
    required ProductFormResult? result,
    Product? initialProduct,
    int? index,
  }) async {
    if (result == null) return;
    if (!mounted) return;

    try {
      final updatedProducts = await _actionCoordinator.applyResult(
        currentProducts: _products,
        result: result,
        initialProduct: initialProduct,
        index: index,
      );

      if (!mounted) return;
      setState(() {
        _products
          ..clear()
          ..addAll(updatedProducts);
      });
    } catch (_) {
      AppNotifications.showDelete('No se pudo guardar el producto en la API.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatalogToolbar(
            searchController: _searchController,
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onViewTap: _openViewModeSelector,
            onSortTap: _openSortModeSelector,
            viewIcon: CatalogDisplayOptions.viewModeIcon(_viewMode),
            viewTooltip:
                'Vista: ${CatalogDisplayOptions.viewModeLabel(_viewMode)}',
            sortIcon: CatalogDisplayOptions.sortModeIcon(_sortMode),
            sortTooltip:
                'Orden: ${CatalogDisplayOptions.sortModeLabel(_sortMode)}',
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: _products.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const AppEmptyState(
                                message: 'Todavia no hay productos agregados.',
                              ),
                            ),
                          )
                        : _visibleProducts.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const Center(
                                child: Text('No se encontraron productos.'),
                              ),
                            ),
                          )
                        : _buildProductsList(),
                  ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: AppCompactActionButton(
              onPressed: _openProductPage,
              icon: Icons.add,
              label: 'Anadir producto',
            ),
          ),
        ],
      ),
    );
  }
}
