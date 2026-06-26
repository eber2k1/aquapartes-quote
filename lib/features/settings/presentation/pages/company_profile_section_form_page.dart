import 'package:flutter/material.dart';

import '../../../../core/services/app_notifications.dart';
import '../../domain/entities/company_profile.dart';
import '../../domain/repositories/company_profile_repository.dart';
import '../../settings_module.dart';
import '../widgets/company_profile_form_sections.dart';

enum CompanyProfileSectionType { general, contact, commercial, defaults }

class CompanyProfileSectionFormPage extends StatefulWidget {
  const CompanyProfileSectionFormPage({
    super.key,
    required this.section,
    required this.initialProfile,
  });

  final CompanyProfileSectionType section;
  final CompanyProfile initialProfile;

  @override
  State<CompanyProfileSectionFormPage> createState() =>
      _CompanyProfileSectionFormPageState();
}

class _CompanyProfileSectionFormPageState
    extends State<CompanyProfileSectionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final CompanyProfileRepository _repository = getCompanyProfileRepository();
  final _cityController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _rucController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _mobileController = TextEditingController();
  final _officePhoneController = TextEditingController();
  final _fiscalAddressController = TextEditingController();
  final _sellerNameController = TextEditingController();
  final _sellerRoleController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  final _saleCurrencyController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  final _deliveryPlaceController = TextEditingController();
  final _quoteValidityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setControllersFromProfile(widget.initialProfile);
  }

  @override
  void dispose() {
    _cityController.dispose();
    _companyNameController.dispose();
    _taglineController.dispose();
    _rucController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _mobileController.dispose();
    _officePhoneController.dispose();
    _fiscalAddressController.dispose();
    _sellerNameController.dispose();
    _sellerRoleController.dispose();
    _paymentTermsController.dispose();
    _saleCurrencyController.dispose();
    _deliveryTimeController.dispose();
    _deliveryPlaceController.dispose();
    _quoteValidityController.dispose();
    super.dispose();
  }

  String get _sectionTitle {
    switch (widget.section) {
      case CompanyProfileSectionType.general:
        return 'Informacion general';
      case CompanyProfileSectionType.contact:
        return 'Contacto';
      case CompanyProfileSectionType.commercial:
        return 'Contacto comercial';
      case CompanyProfileSectionType.defaults:
        return 'Condiciones por defecto';
    }
  }

  String get _saveButtonLabel {
    switch (widget.section) {
      case CompanyProfileSectionType.general:
        return 'Guardar informacion general';
      case CompanyProfileSectionType.contact:
        return 'Guardar contacto';
      case CompanyProfileSectionType.commercial:
        return 'Guardar contacto comercial';
      case CompanyProfileSectionType.defaults:
        return 'Guardar condiciones';
    }
  }

  String? _requiredValidator(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  void _setControllersFromProfile(CompanyProfile profile) {
    _cityController.text = profile.city;
    _companyNameController.text = profile.companyName;
    _taglineController.text = profile.tagline;
    _rucController.text = profile.ruc;
    _emailController.text = profile.email;
    _websiteController.text = profile.website;
    _mobileController.text = profile.mobile;
    _officePhoneController.text = profile.officePhone;
    _fiscalAddressController.text = profile.fiscalAddress;
    _sellerNameController.text = profile.sellerName;
    _sellerRoleController.text = profile.sellerRole;
    _paymentTermsController.text = profile.paymentTerms;
    _saleCurrencyController.text = profile.saleCurrency;
    _deliveryTimeController.text = profile.deliveryTime;
    _deliveryPlaceController.text = profile.deliveryPlace;
    _quoteValidityController.text = profile.quoteValidity;
  }

  CompanyProfile _buildUpdatedProfile() {
    return widget.initialProfile.copyWith(
      city: _cityController.text.trim(),
      companyName: _companyNameController.text.trim(),
      tagline: _taglineController.text.trim(),
      ruc: _rucController.text.trim(),
      email: _emailController.text.trim(),
      website: _websiteController.text.trim(),
      mobile: _mobileController.text.trim(),
      officePhone: _officePhoneController.text.trim(),
      fiscalAddress: _fiscalAddressController.text.trim(),
      sellerName: _sellerNameController.text.trim(),
      sellerRole: _sellerRoleController.text.trim(),
      paymentTerms: _paymentTermsController.text.trim(),
      saleCurrency: _saleCurrencyController.text.trim(),
      deliveryTime: _deliveryTimeController.text.trim(),
      deliveryPlace: _deliveryPlaceController.text.trim(),
      quoteValidity: _quoteValidityController.text.trim(),
    );
  }

  Future<void> _saveSection() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedProfile = _buildUpdatedProfile();
    await _repository.saveProfile(updatedProfile);

    if (!mounted) return;

    AppNotifications.showSuccess('$_sectionTitle guardada correctamente.');

    Navigator.of(context).pop(true);
  }

  Widget _buildSectionForm() {
    switch (widget.section) {
      case CompanyProfileSectionType.general:
        return CompanyProfileGeneralSection(
          companyNameController: _companyNameController,
          taglineController: _taglineController,
          rucController: _rucController,
          cityController: _cityController,
          requiredValidator: _requiredValidator,
        );
      case CompanyProfileSectionType.contact:
        return CompanyProfileContactSection(
          emailController: _emailController,
          websiteController: _websiteController,
          mobileController: _mobileController,
          officePhoneController: _officePhoneController,
          fiscalAddressController: _fiscalAddressController,
          requiredValidator: _requiredValidator,
        );
      case CompanyProfileSectionType.commercial:
        return CompanyProfileCommercialSection(
          sellerNameController: _sellerNameController,
          sellerRoleController: _sellerRoleController,
          requiredValidator: _requiredValidator,
        );
      case CompanyProfileSectionType.defaults:
        return CompanyProfileDefaultsSection(
          paymentTermsController: _paymentTermsController,
          saleCurrencyController: _saleCurrencyController,
          deliveryTimeController: _deliveryTimeController,
          deliveryPlaceController: _deliveryPlaceController,
          quoteValidityController: _quoteValidityController,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_sectionTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionForm(),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saveSection,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_saveButtonLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
