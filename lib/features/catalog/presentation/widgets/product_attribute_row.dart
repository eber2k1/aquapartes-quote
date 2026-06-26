import 'package:flutter/material.dart';

class ProductAttributeRow extends StatelessWidget {
  const ProductAttributeRow({
    super.key,
    required this.nameController,
    required this.valueController,
    required this.onRemove,
  });

  final TextEditingController nameController;
  final TextEditingController valueController;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Caracteristica',
                hintText: 'Ejemplo: Peso',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Valor',
                hintText: 'Ejemplo: 12 kg',
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar caracteristica',
          ),
        ],
      ),
    );
  }
}
