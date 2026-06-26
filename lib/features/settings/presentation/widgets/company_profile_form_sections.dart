import 'package:flutter/material.dart';

import 'company_profile_text_field.dart';

typedef CompanyProfileRequiredValidator =
    String? Function(String? value, String message);

class CompanyProfileGeneralSection extends StatelessWidget {
  const CompanyProfileGeneralSection({
    super.key,
    required this.companyNameController,
    required this.taglineController,
    required this.rucController,
    required this.cityController,
    required this.requiredValidator,
  });

  final TextEditingController companyNameController;
  final TextEditingController taglineController;
  final TextEditingController rucController;
  final TextEditingController cityController;
  final CompanyProfileRequiredValidator requiredValidator;

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
            Text(
              'Informacion general',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: companyNameController,
              label: 'Razon social',
              validator: (value) =>
                  requiredValidator(value, 'Ingresa la razon social'),
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: taglineController,
              label: 'Descripcion corta',
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: rucController,
              label: 'RUC',
              keyboardType: TextInputType.number,
              validator: (value) => requiredValidator(value, 'Ingresa el RUC'),
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: cityController,
              label: 'Ciudad',
              validator: (value) =>
                  requiredValidator(value, 'Ingresa la ciudad'),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyProfileContactSection extends StatelessWidget {
  const CompanyProfileContactSection({
    super.key,
    required this.emailController,
    required this.websiteController,
    required this.mobileController,
    required this.officePhoneController,
    required this.fiscalAddressController,
    required this.requiredValidator,
  });

  final TextEditingController emailController;
  final TextEditingController websiteController;
  final TextEditingController mobileController;
  final TextEditingController officePhoneController;
  final TextEditingController fiscalAddressController;
  final CompanyProfileRequiredValidator requiredValidator;

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
            Text(
              'Contacto',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: emailController,
              label: 'Correo',
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  requiredValidator(value, 'Ingresa el correo'),
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: websiteController,
              label: 'Sitio web',
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: mobileController,
              label: 'Celular',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: officePhoneController,
              label: 'Telefono de oficina',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: fiscalAddressController,
              label: 'Direccion fiscal',
              maxLines: 2,
              validator: (value) =>
                  requiredValidator(value, 'Ingresa la direccion fiscal'),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyProfileCommercialSection extends StatelessWidget {
  const CompanyProfileCommercialSection({
    super.key,
    required this.sellerNameController,
    required this.sellerRoleController,
    required this.requiredValidator,
  });

  final TextEditingController sellerNameController;
  final TextEditingController sellerRoleController;
  final CompanyProfileRequiredValidator requiredValidator;

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
            Text(
              'Contacto comercial',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: sellerNameController,
              label: 'Nombre del responsable comercial',
              validator: (value) =>
                  requiredValidator(value, 'Ingresa el nombre del responsable'),
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: sellerRoleController,
              label: 'Puesto del responsable',
              validator: (value) =>
                  requiredValidator(value, 'Ingresa el puesto'),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyProfileDefaultsSection extends StatelessWidget {
  const CompanyProfileDefaultsSection({
    super.key,
    required this.paymentTermsController,
    required this.saleCurrencyController,
    required this.deliveryTimeController,
    required this.deliveryPlaceController,
    required this.quoteValidityController,
  });

  final TextEditingController paymentTermsController;
  final TextEditingController saleCurrencyController;
  final TextEditingController deliveryTimeController;
  final TextEditingController deliveryPlaceController;
  final TextEditingController quoteValidityController;

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
            Text(
              'Condiciones por defecto',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: paymentTermsController,
              label: 'Forma de pago',
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: saleCurrencyController,
              label: 'Moneda o valores de venta',
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: deliveryTimeController,
              label: 'Tiempo de entrega',
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: deliveryPlaceController,
              label: 'Lugar de entrega',
            ),
            const SizedBox(height: 16),
            CompanyProfileTextField(
              controller: quoteValidityController,
              label: 'Validez de cotizacion',
            ),
          ],
        ),
      ),
    );
  }
}
