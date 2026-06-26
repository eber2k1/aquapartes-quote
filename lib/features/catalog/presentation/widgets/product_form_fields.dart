import 'package:flutter/material.dart';

class ProductFormFields extends StatelessWidget {
  const ProductFormFields({
    super.key,
    required this.nameController,
    required this.categoryController,
    required this.categoryOptions,
    required this.brandController,
    required this.brandOptions,
    required this.originController,
    required this.modelController,
    required this.priceController,
    required this.nameValidator,
  });

  final TextEditingController nameController;
  final TextEditingController categoryController;
  final List<String> categoryOptions;
  final TextEditingController brandController;
  final List<String> brandOptions;
  final TextEditingController originController;
  final TextEditingController modelController;
  final TextEditingController priceController;
  final FormFieldValidator<String> nameValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Descripcion del producto',
          ),
          validator: nameValidator,
        ),
        const SizedBox(height: 16),
        _SelectableTextFormField(
          controller: categoryController,
          labelText: 'Categoria',
          options: categoryOptions,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ingresa la categoria';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _SelectableTextFormField(
          controller: brandController,
          labelText: 'Marca',
          options: brandOptions,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: originController,
          decoration: const InputDecoration(labelText: 'Procedencia'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: modelController,
          decoration: const InputDecoration(labelText: 'Modelo'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Precio base'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ingresa el precio';
            }

            final price = double.tryParse(value.trim());
            if (price == null) {
              return 'Ingresa un numero valido';
            }

            if (price < 0) {
              return 'El precio no puede ser negativo';
            }

            return null;
          },
        ),
      ],
    );
  }
}

class _SelectableTextFormField extends StatelessWidget {
  const _SelectableTextFormField({
    required this.controller,
    required this.labelText,
    required this.options,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final List<String> options;
  final FormFieldValidator<String>? validator;

  Future<void> _openOptions(BuildContext context) async {
    final selectedValue = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Seleccionar $labelText',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final option = options[index];

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        title: Text(option),
                        onTap: () => Navigator.of(context).pop(option),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedValue == null) return;
    controller.text = selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,

        suffixIcon: options.isEmpty
            ? null
            : IconButton(
                onPressed: () => _openOptions(context),
                icon: const Icon(Icons.arrow_drop_down_rounded),
                tooltip: 'Seleccionar $labelText',
              ),
      ),
      validator: validator,
    );
  }
}
