import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/services/app_notifications.dart';
import '../../../auth/auth_module.dart';
import '../../catalog_module.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../helpers/product_media_helper.dart';
import '../models/product_attributes_field_controllers.dart';
import '../models/product_form_result.dart';
import '../widgets/product_attributes_section.dart';
import '../widgets/product_form_fields.dart';
import '../widgets/product_media_section.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({
    super.key,
    this.initialProduct,
    this.existingProducts = const [],
  });

  final Product? initialProduct;
  final List<Product> existingProducts;

  bool get isEditing => initialProduct != null;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final CatalogRepository _repository = getCatalogRepository();
  late final ProductMediaHelper _mediaHelper = ProductMediaHelper(
    repository: _repository,
  );
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _originController = TextEditingController();
  final _modelController = TextEditingController();
  final List<ProductAttributeFieldControllers> _attributeFields = [];
  List<String> _similarProductNames = [];
  String _imageUrl = '';
  String _imageFileName = '';
  String _technicalSheetUrl = '';
  String _technicalSheetFileName = '';
  bool _isUploadingFile = false;

  List<String> get _categoryOptions {
    return widget.existingProducts
        .map((product) => product.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> get _brandOptions {
    return widget.existingProducts
        .map((product) => product.brand.trim())
        .where((brand) => brand.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);

    final initialProduct = widget.initialProduct;
    if (initialProduct == null) return;

    _nameController.text = initialProduct.name;
    _priceController.text = initialProduct.basePrice.toStringAsFixed(2);
    _categoryController.text = initialProduct.category;
    _brandController.text = initialProduct.brand;
    _originController.text = initialProduct.origin;
    _modelController.text = initialProduct.model;
    _imageUrl = initialProduct.imageUrl;
    _imageFileName = initialProduct.imageFileName;
    _technicalSheetUrl = initialProduct.technicalSheetUrl;
    _technicalSheetFileName = initialProduct.technicalSheetFileName;
    _attributeFields.addAll(
      initialProduct.attributes.map(
        (attribute) =>
            ProductAttributeFieldControllers.fromAttribute(attribute),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _originController.dispose();
    _modelController.dispose();
    for (final fields in _attributeFields) {
      fields.dispose();
    }
    super.dispose();
  }

  void _addAttribute() {
    setState(() {
      _attributeFields.add(ProductAttributeFieldControllers.empty());
    });
  }

  void _onNameChanged() {
    final input = _nameController.text.trim().toLowerCase();

    if (input.length < 4) {
      if (_similarProductNames.isNotEmpty) {
        setState(() => _similarProductNames.clear());
      }
      return;
    }

    final currentName = widget.initialProduct?.name.trim().toLowerCase();
    final inputTokens = input
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2)
        .toSet();

    final similars = widget.existingProducts
        .where((product) {
          final existingName = product.name.trim().toLowerCase();
          if (currentName != null && existingName == currentName) {
            return false;
          }

          // Coincidencia exacta o si contiene el texto completo
          if (existingName == input || existingName.contains(input)) {
            return true;
          }

          // Coincidencia por palabras (interseccion de tokens)
          final existingTokens = existingName
              .split(RegExp(r'\s+'))
              .where((t) => t.length > 2)
              .toSet();
          final intersection = inputTokens.intersection(existingTokens);

          return intersection.length >= 2;
        })
        .take(3)
        .map((p) => p.name)
        .toList();

    bool listsAreEqual = _similarProductNames.length == similars.length;
    if (listsAreEqual) {
      for (int i = 0; i < similars.length; i++) {
        if (_similarProductNames[i] != similars[i]) {
          listsAreEqual = false;
          break;
        }
      }
    }

    if (!listsAreEqual) {
      setState(() {
        _similarProductNames = similars;
      });
    }
  }

  void _removeAttribute(int index) {
    setState(() {
      final fields = _attributeFields.removeAt(index);
      fields.dispose();
    });
  }

  List<ProductAttribute>? _collectAttributes() {
    final attributes = <ProductAttribute>[];

    for (final fields in _attributeFields) {
      final name = fields.nameController.text.trim();
      final value = fields.valueController.text.trim();

      if (name.isEmpty && value.isEmpty) {
        continue;
      }

      if (name.isEmpty || value.isEmpty) {
        _showMessage(
          'Completa el nombre y valor de cada caracteristica o elimina la fila vacia.',
        );
        return null;
      }

      attributes.add(ProductAttribute(name: name, value: value));
    }

    return attributes;
  }

  void _showMessage(String message) {
    AppNotifications.showInfo(message);
  }

  Future<void> _selectExistingImage() async {
    await _mediaHelper.selectExistingImage(
      context: context,
      onSelected: (file) {
        setState(() {
          _imageUrl = file.url;
          _imageFileName = file.label;
        });
      },
    );
  }

  Future<void> _selectExistingTechnicalSheet() async {
    await _mediaHelper.selectExistingTechnicalSheet(
      context: context,
      onSelected: (file) {
        setState(() {
          _technicalSheetUrl = file.url;
          _technicalSheetFileName = file.label;
        });
      },
    );
  }

  Future<void> _uploadNewImage() async {
    await _mediaHelper.uploadNewImage(
      context: context,
      onUploaded: (url, fileName) {
        setState(() {
          _imageUrl = url;
          _imageFileName = fileName;
        });
      },
      onBusyChanged: _updateUploadingState,
    );
  }

  Future<void> _uploadNewTechnicalSheet() async {
    await _mediaHelper.uploadNewTechnicalSheet(
      context: context,
      onUploaded: (url, fileName) {
        setState(() {
          _technicalSheetUrl = url;
          _technicalSheetFileName = fileName;
        });
      },
      onBusyChanged: _updateUploadingState,
    );
  }

  Future<void> _viewImage() async {
    await _mediaHelper.showImagePreview(context: context, imageUrl: _imageUrl);
  }

  Future<void> _viewTechnicalSheet() async {
    if (_technicalSheetUrl.trim().isEmpty) return;
    await _mediaHelper.openUrl(context, _technicalSheetUrl);
  }

  void _updateUploadingState(bool isBusy) {
    if (!mounted) return;
    setState(() {
      _isUploadingFile = isBusy;
    });
  }

  String? _validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa la descripcion del producto';
    }

    final normalizedName = value.trim().toLowerCase();
    final currentName = widget.initialProduct?.name.trim().toLowerCase();

    final isDuplicate = widget.existingProducts.any((product) {
      final existingName = product.name.trim().toLowerCase();

      if (currentName != null && existingName == currentName) {
        return false;
      }

      return existingName == normalizedName;
    });

    if (isDuplicate) {
      return 'Ya existe un producto con ese nombre';
    }

    return null;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    final attributes = _collectAttributes();
    if (attributes == null) return;
    final session = await getAuthRepository().loadSession();
    if (!mounted) return;
    final initialCreatedBy = widget.initialProduct?.createdBy.trim() ?? '';

    final product = Product(
      id: widget.initialProduct?.id,
      name: _nameController.text.trim(),
      basePrice: double.parse(_priceController.text.trim()),
      category: _categoryController.text.trim(),
      brand: _brandController.text.trim(),
      origin: _originController.text.trim(),
      model: _modelController.text.trim(),
      imageUrl: _imageUrl,
      imageFileName: _imageFileName,
      technicalSheetUrl: _technicalSheetUrl,
      technicalSheetFileName: _technicalSheetFileName,
      currency: widget.initialProduct?.currency ?? 'USD',
      isActive: widget.initialProduct?.isActive ?? true,
      createdBy: initialCreatedBy.isNotEmpty
          ? initialCreatedBy
          : session?.user.id ?? '',
      createdAt: widget.initialProduct?.createdAt,
      updatedAt: widget.initialProduct?.updatedAt,
      deletedAt: widget.initialProduct?.deletedAt,
      attributes: attributes,
    );

    Navigator.of(context).pop(ProductFormResult.saved(product));
  }

  Future<void> _deleteProduct() async {
    final shouldDelete = await AppConfirmationDialog.show(
      context,
      title: 'Eliminar producto',
      content:
          'Este producto se eliminara del catalogo. Esta accion no se puede deshacer.',
      confirmText: 'Eliminar',
      isDestructive: true,
    );

    if (!shouldDelete || !mounted) return;

    Navigator.of(context).pop(const ProductFormResult.deleted());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar producto' : 'Anadir producto'),
      ),
      body: SafeArea(
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
                        'Datos basicos',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ProductFormFields(
                        nameController: _nameController,
                        categoryController: _categoryController,
                        categoryOptions: _categoryOptions,
                        brandController: _brandController,
                        brandOptions: _brandOptions,
                        originController: _originController,
                        modelController: _modelController,
                        priceController: _priceController,
                        nameValidator: _validateProductName,
                        similarProductNames: _similarProductNames,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ProductMediaSection(
                  imageUrl: _imageUrl,
                  imageFileName: _imageFileName,
                  technicalSheetUrl: _technicalSheetUrl,
                  technicalSheetFileName: _technicalSheetFileName,
                  isBusy: _isUploadingFile,
                  onViewImage: _viewImage,
                  onViewTechnicalSheet: _viewTechnicalSheet,
                  onSelectExistingImage: _selectExistingImage,
                  onUploadNewImage: _uploadNewImage,
                  onClearImage: () {
                    setState(() {
                      _imageUrl = '';
                      _imageFileName = '';
                    });
                  },
                  onSelectExistingTechnicalSheet: _selectExistingTechnicalSheet,
                  onUploadNewTechnicalSheet: _uploadNewTechnicalSheet,
                  onClearTechnicalSheet: () {
                    setState(() {
                      _technicalSheetUrl = '';
                      _technicalSheetFileName = '';
                    });
                  },
                ),
                const SizedBox(height: 24),
                ProductAttributesSection(
                  attributeFields: _attributeFields,
                  onAddAttribute: _addAttribute,
                  onRemoveAttribute: _removeAttribute,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saveProduct,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    widget.isEditing ? 'Guardar cambios' : 'Guardar producto',
                  ),
                ),
                if (widget.isEditing) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _deleteProduct,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar producto'),
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
