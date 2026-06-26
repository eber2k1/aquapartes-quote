import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import 'catalog_product_card.dart';

class CatalogGroupSection extends StatelessWidget {
  const CatalogGroupSection({
    super.key,
    required this.title,
    required this.products,
    required this.onProductTap,
    this.isAdmin = false,
  });

  final String title;
  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(title),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: theme.colorScheme.primary,
          collapsedIconColor: theme.colorScheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${products.length} producto${products.length == 1 ? '' : 's'}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.expand_more_rounded),
            ],
          ),
          children: products.asMap().entries.map((entry) {
            final product = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == products.length - 1 ? 0 : 10,
              ),
              child: CatalogProductCard(
                product: product,
                onTap: () => onProductTap(product),
                grouped: true,
                isAdmin: isAdmin,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
