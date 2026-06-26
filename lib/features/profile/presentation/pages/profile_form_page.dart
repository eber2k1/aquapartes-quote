import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/user_profile.dart';

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key, required this.initialProfile});

  final UserProfile initialProfile;

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _paternalLastNameController = TextEditingController();
  final _maternalLastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.initialProfile.firstNames;
    _paternalLastNameController.text = widget.initialProfile.paternalLastName;
    _maternalLastNameController.text = widget.initialProfile.maternalLastName;
    _phoneController.text = widget.initialProfile.phone;
    _positionController.text = widget.initialProfile.position;
    _emailController.text = widget.initialProfile.email;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _paternalLastNameController.dispose();
    _maternalLastNameController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final profile = UserProfile(
      paternalLastName: _paternalLastNameController.text.trim(),
      maternalLastName: _maternalLastNameController.text.trim(),
      firstNames: _firstNameController.text.trim(),
      phone: _phoneController.text.trim(),
      position: _positionController.text.trim(),
      email: _emailController.text.trim(),
    );

    Navigator.of(context).pop(profile);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
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
                        'Informacion personal',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombres',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
                            _requiredValidator(value, 'Ingresa los nombres'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _paternalLastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Apellido paterno',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (value) => _requiredValidator(
                          value,
                          'Ingresa el apellido paterno',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _maternalLastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Apellido materno',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (value) => _requiredValidator(
                          value,
                          'Ingresa el apellido materno',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Informacion de contacto',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Numero',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) =>
                            _requiredValidator(value, 'Ingresa el numero'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _positionController,
                        decoration: const InputDecoration(
                          labelText: 'Puesto',
                          prefixIcon: Icon(Icons.work_outline),
                        ),
                        validator: (value) =>
                            _requiredValidator(value, 'Ingresa el puesto'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) =>
                            _requiredValidator(value, 'Ingresa el correo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
