import 'package:flutter/material.dart';

import '../../../../core/services/app_notifications.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../domain/entities/system_user.dart';
import '../../domain/repositories/users_repository.dart';
import '../../users_module.dart';

class UserFormPage extends StatefulWidget {
  const UserFormPage({super.key, this.initialUser});

  final SystemUser? initialUser;

  bool get isEditing => initialUser != null;

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final UsersRepository _repository = getUsersRepository();

  final _firstNameController = TextEditingController();
  final _lastNamePaternalController = TextEditingController();
  final _lastNameMaternalController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();

  String _selectedRole = 'sales';
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialUser != null) {
      final u = widget.initialUser!;
      _firstNameController.text = u.firstName;
      _lastNamePaternalController.text = u.lastNamePaternal;
      _lastNameMaternalController.text = u.lastNameMaternal;
      _emailController.text = u.email;
      _phoneController.text = u.phone;
      _positionController.text = u.position;
      _selectedRole = (u.role.isEmpty || u.role == 'user') ? 'sales' : u.role;
      _isActive = u.isActive;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNamePaternalController.dispose();
    _lastNameMaternalController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final user = SystemUser(
      id: widget.initialUser?.id ?? '',
      email: _emailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastNamePaternal: _lastNamePaternalController.text.trim(),
      lastNameMaternal: _lastNameMaternalController.text.trim(),
      phone: _phoneController.text.trim(),
      position: _positionController.text.trim(),
      role: _selectedRole,
      isActive: _isActive,
    );

    try {
      if (widget.isEditing) {
        await _repository.updateUser(user);
        AppNotifications.showSuccess('Usuario actualizado correctamente.');
      } else {
        await _repository.createUser(user);
        AppNotifications.showSuccess('Usuario creado correctamente.');
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        AppNotifications.showDelete('Error al guardar: $msg');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _delete() async {
    if (widget.initialUser == null) return;

    final confirm = await AppConfirmationDialog.show(
      context,
      title: 'Eliminar usuario',
      content:
          '¿Estas seguro de eliminar este usuario? Esta accion no se puede deshacer.',
      confirmText: 'Eliminar',
      isDestructive: true,
    );

    if (!confirm || !mounted) return;

    setState(() => _isSaving = true);

    try {
      await _repository.deleteUser(widget.initialUser!.id);
      AppNotifications.showSuccess('Usuario eliminado correctamente.');
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        AppNotifications.showDelete('Error al eliminar: $msg');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Usuario' : 'Nuevo Usuario'),
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
                        'Datos Personales',
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNamePaternalController,
                        decoration: const InputDecoration(
                          labelText: 'Apellido Paterno',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameMaternalController,
                        decoration: const InputDecoration(
                          labelText: 'Apellido Materno',
                          prefixIcon: Icon(Icons.person_outline),
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
                        'Contacto y Acceso',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Correo electronico',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          final regex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!regex.hasMatch(value)) {
                            return 'Correo no valido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefono',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _positionController,
                        decoration: const InputDecoration(
                          labelText: 'Cargo',
                          prefixIcon: Icon(Icons.badge_outlined),
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
                        'Permisos',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Rol del usuario',
                          prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'sales',
                            child: Text('Vendedor (Sales)'),
                          ),
                          DropdownMenuItem(
                            value: 'manager',
                            child: Text('Gerente (Manager)'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Administrador'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedRole = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Cuenta activa'),
                        subtitle: const Text(
                          'Permite al usuario iniciar sesion',
                        ),
                        value: _isActive,
                        onChanged: (val) => setState(() => _isActive = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    widget.isEditing ? 'Guardar Cambios' : 'Crear Usuario',
                  ),
                ),
                if (widget.isEditing) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isSaving ? null : _delete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar Usuario'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
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
