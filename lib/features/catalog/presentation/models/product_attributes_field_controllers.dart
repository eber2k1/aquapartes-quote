import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';

class ProductAttributeFieldControllers {
  ProductAttributeFieldControllers({
    required this.nameController,
    required this.valueController,
  });

  factory ProductAttributeFieldControllers.empty() {
    return ProductAttributeFieldControllers(
      nameController: TextEditingController(),
      valueController: TextEditingController(),
    );
  }

  factory ProductAttributeFieldControllers.fromAttribute(
    ProductAttribute attribute,
  ) {
    return ProductAttributeFieldControllers(
      nameController: TextEditingController(text: attribute.name),
      valueController: TextEditingController(text: attribute.value),
    );
  }

  final TextEditingController nameController;
  final TextEditingController valueController;

  void dispose() {
    nameController.dispose();
    valueController.dispose();
  }
}
