import 'package:flutter/material.dart';

import '../../../../core/services/app_notifications.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_list_tile.dart';
import '../../../auth/auth_module.dart';
import '../../../auth/domain/entities/auth_session.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../profile_module.dart';
import 'profile_form_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.isGuestMode,
    required this.onSignOut,
  });

  final bool isGuestMode;
  final Future<void> Function() onSignOut;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileRepository _repository = getProfileRepository();
  UserProfile _profile = const UserProfile(
    paternalLastName: '',
    maternalLastName: '',
    firstNames: '',
    phone: '',
    position: '',
    email: '',
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (widget.isGuestMode) {
      if (!mounted) return;
      setState(() {
        _profile = const UserProfile(
          paternalLastName: '',
          maternalLastName: '',
          firstNames: 'Invitado',
          phone: '',
          position: 'Modo offline',
          email: '',
        );
        _isLoading = false;
      });
      return;
    }

    final savedProfile = await _repository.loadProfile();
    final session = await getAuthRepository().loadSession();
    final sessionProfile = _profileFromSession(session);

    if (!mounted) return;

    UserProfile? profileToUse;
    if (sessionProfile != null) {
      profileToUse = sessionProfile;
      // Actualizar el perfil guardado con los datos de la sesión
      await _repository.saveProfile(sessionProfile);
    } else if (savedProfile != null) {
      profileToUse = savedProfile;
    }

    setState(() {
      if (profileToUse != null) {
        _profile = profileToUse;
      }
      _isLoading = false;
    });
  }

  UserProfile? _profileFromSession(AuthSession? session) {
    final user = session?.user;
    if (user == null) {
      return null;
    }

    return UserProfile(
      paternalLastName: user.lastNamePaternal,
      maternalLastName: user.lastNameMaternal,
      firstNames: user.firstName,
      phone: user.phone,
      position: user.position,
      email: user.email,
    );
  }

  Future<void> _openEditProfilePage() async {
    final updatedProfile = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(
        builder: (_) => ProfileFormPage(initialProfile: _profile),
      ),
    );

    if (updatedProfile == null || !mounted) return;

    await _repository.saveProfile(updatedProfile);
    if (!mounted) return;

    setState(() {
      _profile = updatedProfile;
    });

    AppNotifications.showSuccess('Perfil actualizado correctamente.');
  }

  String _displayValue(String value) {
    return value.trim().isEmpty ? '-' : value.trim();
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await AppConfirmationDialog.show(
      context,
      title: widget.isGuestMode ? 'Salir del modo invitado' : 'Cerrar sesion',
      content: widget.isGuestMode
          ? '¿Quieres salir del modo invitado y volver al inicio?'
          : '¿Estas seguro que quieres cerrar sesion?',
      confirmText: widget.isGuestMode ? 'Salir' : 'Cerrar sesion',
      isDestructive: true,
    );

    if (shouldLogout && mounted) {
      await widget.onSignOut();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              _profile.firstNames.isNotEmpty
                                  ? _profile.firstNames[0].toUpperCase()
                                  : 'U',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!widget.isGuestMode)
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.scaffoldBackgroundColor,
                                  width: 3,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                color: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                                onPressed: _openEditProfilePage,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _profile.fullName.isEmpty
                          ? 'Perfil de usuario'
                          : _profile.fullName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_profile.position.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        _profile.position.trim(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withAlpha(
                            128,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          AppListTile(
                            icon: Icons.person_outline,
                            title: 'Apellido paterno',
                            subtitle: _displayValue(_profile.paternalLastName),
                          ),
                          AppListTile(
                            icon: Icons.person_outline,
                            title: 'Apellido materno',
                            subtitle: _displayValue(_profile.maternalLastName),
                          ),
                          AppListTile(
                            icon: Icons.badge_outlined,
                            title: 'Nombres',
                            subtitle: _displayValue(_profile.firstNames),
                          ),
                          AppListTile(
                            icon: Icons.phone_outlined,
                            title: 'Numero',
                            subtitle: _displayValue(_profile.phone),
                          ),
                          AppListTile(
                            icon: Icons.email_outlined,
                            title: 'Correo',
                            subtitle: _displayValue(_profile.email),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: _handleLogout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.logout_outlined),
                      label: Text(
                        widget.isGuestMode
                            ? 'Salir del modo invitado'
                            : 'Cerrar sesión',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
