import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../../core/services/app_notifications.dart';
import '../../../auth/auth_module.dart';
import '../../domain/entities/customer.dart';
import '../models/customer_form_result.dart';

class CustomerFormPage extends StatefulWidget {
  const CustomerFormPage({super.key, this.initialCustomer});

  final Customer? initialCustomer;

  bool get isEditing => initialCustomer != null;

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _contactNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final initialCustomer = widget.initialCustomer;
    if (initialCustomer == null) return;

    _contactNameController.text = initialCustomer.contactName;
    _phoneController.text = initialCustomer.phone;
    _companyNameController.text = initialCustomer.companyName;
    _emailController.text = initialCustomer.email;
    _addressController.text = initialCustomer.address;
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final initialCustomer = widget.initialCustomer;
    final session = await getAuthRepository().loadSession();
    if (!mounted) return;
    final customer = Customer(
      id: initialCustomer?.id,
      contactName: _contactNameController.text.trim(),
      phone: _phoneController.text.trim(),
      companyName: _companyNameController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      createdBy: (initialCustomer?.createdBy.trim().isNotEmpty ?? false)
          ? initialCustomer!.createdBy
          : session?.user.id ?? '',
      createdAt: initialCustomer?.createdAt,
      updatedAt: initialCustomer?.updatedAt,
      deletedAt: initialCustomer?.deletedAt,
    );

    Navigator.of(context).pop(CustomerFormResult.saved(customer));
  }

  Future<void> _deleteCustomer() async {
    final shouldDelete = await AppConfirmationDialog.show(
      context,
      title: 'Eliminar cliente',
      content:
          'Este cliente se eliminara permanentemente. Esta accion no se puede deshacer.',
      confirmText: 'Eliminar',
      isDestructive: true,
    );

    if (!shouldDelete || !mounted) return;

    Navigator.of(context).pop(const CustomerFormResult.deleted());
  }

  Future<void> _importContact() async {
    try {
      final status = await FlutterContacts.permissions.request(
        PermissionType.read,
      );
      if (status != PermissionStatus.granted &&
          status != PermissionStatus.limited) {
        AppNotifications.showInfo(
          'Permiso denegado para acceder a los contactos.',
        );
        return;
      }

      final contact = await FlutterContacts.native.showPicker(
        properties: {
          ContactProperty.phone,
          ContactProperty.email,
          ContactProperty.organization,
          ContactProperty.address,
        },
      );

      if (contact == null) return;

      setState(() {
        _contactNameController.text = contact.displayName ?? '';
        if (contact.phones.isNotEmpty) {
          _phoneController.text = contact.phones.first.number;
        }
        if (contact.emails.isNotEmpty) {
          _emailController.text = contact.emails.first.address;
        }
        if (contact.organizations.isNotEmpty) {
          _companyNameController.text = contact.organizations.first.name ?? '';
        } else {
          _companyNameController.text = contact.displayName ?? '';
        }
        if (contact.addresses.isNotEmpty) {
          _addressController.text = contact.addresses.first.formatted ?? '';
        }
      });
      AppNotifications.showInfo('Contacto importado correctamente.');
    } catch (e) {
      AppNotifications.showDelete('Error al importar el contacto.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar cliente' : 'Anadir cliente'),
        actions: [
          if (!widget.isEditing)
            IconButton(
              icon: const Icon(Icons.contact_phone_outlined),
              tooltip: 'Importar desde contactos',
              onPressed: _importContact,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Datos del cliente',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _companyNameController,
                          decoration: const InputDecoration(
                            labelText: 'Empresa o razon social',
                            prefixIcon: Icon(Icons.business_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa la empresa o razon social';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _contactNameController,
                          decoration: const InputDecoration(
                            labelText: 'Persona de contacto',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa la persona de contacto';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Telefono',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa el telefono';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo (Opcional)',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Direccion (Opcional)',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saveCustomer,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    widget.isEditing ? 'Guardar cambios' : 'Guardar cliente',
                  ),
                ),
                if (widget.isEditing) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _deleteCustomer,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar cliente'),
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
