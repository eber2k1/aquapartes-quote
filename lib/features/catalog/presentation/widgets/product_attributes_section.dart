import 'package:flutter/material.dart';

import '../models/product_attributes_field_controllers.dart';
import 'product_attribute_row.dart';

class ProductAttributesSection extends StatelessWidget {
  const ProductAttributesSection({
    super.key,
    required this.attributeFields,
    required this.onAddAttribute,
    required this.onRemoveAttribute,
  });

  final List<ProductAttributeFieldControllers> attributeFields;
  final VoidCallback onAddAttribute;
  final ValueChanged<int> onRemoveAttribute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(128),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Caracteristicas adicionales',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: onAddAttribute,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (attributeFields.isEmpty)
              Text(
                'Agrega solo las caracteristicas que apliquen a este producto.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              Column(
                children: List.generate(attributeFields.length, (index) {
                  final fields = attributeFields[index];

                  return ProductAttributeRow(
                    nameController: fields.nameController,
                    valueController: fields.valueController,
                    onRemove: () => onRemoveAttribute(index),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}
