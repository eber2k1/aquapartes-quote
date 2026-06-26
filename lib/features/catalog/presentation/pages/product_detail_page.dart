import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/app_list_tile.dart';
import '../../domain/entities/product.dart';
import '../models/product_form_result.dart';
import 'product_form_page.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.product,
    this.existingProducts = const [],
    this.isAdmin = false,
  });

  final Product product;
  final List<Product> existingProducts;
  final bool isAdmin;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedSegment = 0;

  Product get product => widget.product;

  Future<void> _openEditPage() async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<ProductFormResult>(
      MaterialPageRoute(
        builder: (_) => ProductFormPage(
          initialProduct: product,
          existingProducts: widget.existingProducts,
        ),
      ),
    );

    if (result == null || !mounted) return;
    navigator.pop(result);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _displayValue(String value) {
    return value.trim().isEmpty ? '-' : value.trim();
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: product.imageUrl.trim().isEmpty
                  ? Icon(
                      Icons.inventory_2_outlined,
                      size: 34,
                      color: theme.colorScheme.primary,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) {
                            return Icon(
                              Icons.inventory_2_outlined,
                              size: 34,
                              color: theme.colorScheme.primary,
                            );
                          },
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              _displayValue(product.name),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              _displayValue(product.brand),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSegment(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Imagen del producto',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (product.imageUrl.trim().isEmpty)
                  _EmptyMediaCard(
                    icon: Icons.image_outlined,
                    message: 'Este producto no tiene imagen registrada.',
                  )
                else ...[
                  Container(
                    height: 260,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) {
                          return const _EmptyMediaCard(
                            icon: Icons.broken_image_outlined,
                            message: 'No se pudo cargar la imagen.',
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _displayValue(product.imageFileName),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _openUrl(product.imageUrl),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Ver imagen'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ficha tecnica PDF',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (product.technicalSheetUrl.trim().isEmpty)
                  _EmptyMediaCard(
                    icon: Icons.picture_as_pdf_outlined,
                    message: 'Este producto no tiene ficha tecnica registrada.',
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _displayValue(product.technicalSheetFileName),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _openUrl(product.technicalSheetUrl),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Ver PDF'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
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
                icon: Icons.category_outlined,
                title: 'Categoria',
                subtitle: _displayValue(product.category),
              ),
              AppListTile(
                icon: Icons.branding_watermark_outlined,
                title: 'Marca',
                subtitle: _displayValue(product.brand),
              ),
              AppListTile(
                icon: Icons.public_outlined,
                title: 'Procedencia',
                subtitle: _displayValue(product.origin),
              ),
              AppListTile(
                icon: Icons.tag_outlined,
                title: 'Modelo',
                subtitle: _displayValue(product.model),
              ),
              AppListTile(
                icon: Icons.payments_outlined,
                title: 'Precio base',
                subtitle: 'US \$${product.basePrice.toStringAsFixed(2)}',
              ),
              AppListTile(
                icon: Icons.attach_money_outlined,
                title: 'Moneda',
                subtitle: _displayValue(product.currency),
                isLast: product.attributes.isEmpty && !widget.isAdmin,
              ),
              if (widget.isAdmin) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                  child: Text(
                    'SISTEMA',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                AppListTile(
                  icon: Icons.person_outline,
                  title: 'Registrado por',
                  subtitle:
                      (product.createdByUserName != null &&
                          product.createdByUserName!.isNotEmpty)
                      ? product.createdByUserName!
                      : (product.createdBy.isNotEmpty
                            ? 'Admin / Sistema'
                            : 'Desconocido'),
                  isLast: product.attributes.isEmpty,
                ),
              ],
              if (product.attributes.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                  child: Text(
                    'CARACTERISTICAS EXTRA',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                ...product.attributes.asMap().entries.map((entry) {
                  final attribute = entry.value;
                  return AppListTile(
                    icon: Icons.info_outline,
                    title: attribute.name,
                    subtitle: _displayValue(attribute.value),
                    isLast: entry.key == product.attributes.length - 1,
                  );
                }),
              ],
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
      appBar: AppBar(
        title: const Text('Producto'),
        actions: [
          IconButton(
            onPressed: _openEditPage,
            tooltip: 'Editar producto',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
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
                        label: Text('Archivos'),
                        icon: Icon(Icons.attach_file_outlined),
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
                  ? _buildMediaSegment(theme)
                  : _buildInfoSegment(),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMediaCard extends StatelessWidget {
  const _EmptyMediaCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
