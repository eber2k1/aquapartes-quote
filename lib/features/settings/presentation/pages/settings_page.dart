import 'package:flutter/material.dart';

import '../../../auth/domain/entities/auth_session.dart';
import '../../../auth/auth_module.dart';
import '../../../users/presentation/pages/users_page.dart';
import 'company_profile_page.dart';
import '../widgets/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.isGuestMode,
    required this.isDarkMode,
    required this.isOfflineMode,
    required this.onThemeModeChanged,
    required this.onOfflineModeChanged,
  });

  final bool isGuestMode;
  final bool isDarkMode;
  final bool isOfflineMode;
  final ValueChanged<bool> onThemeModeChanged;
  final ValueChanged<bool> onOfflineModeChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  AuthSession? _session;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await getAuthRepository().loadSession();
    if (mounted) {
      setState(() {
        _session = session;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = _session?.user.role == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withAlpha(128),
              ),
            ),
            child: SwitchListTile(
              value: widget.isDarkMode,
              onChanged: widget.onThemeModeChanged,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              secondary: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(128),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.dark_mode_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: Text(
                'Modo nocturno',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Activa el tema oscuro para toda la aplicacion.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withAlpha(128),
              ),
            ),
            child: SwitchListTile(
              value: widget.isOfflineMode,
              onChanged: widget.onOfflineModeChanged,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              secondary: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.isOfflineMode
                      ? theme.colorScheme.errorContainer.withAlpha(128)
                      : theme.colorScheme.secondaryContainer.withAlpha(128),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.isOfflineMode
                      ? Icons.cloud_off_outlined
                      : Icons.cloud_done_outlined,
                  color: widget.isOfflineMode
                      ? theme.colorScheme.error
                      : theme.colorScheme.secondary,
                ),
              ),
              title: Text(
                'Modo sin conexion',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Fuerza a la app a usar solo la base de datos local y bloquea internet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 24),
            Text(
              'Administracion',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SettingsTile(
              icon: Icons.people_outline,
              title: 'Gestion de Usuarios',
              subtitle: 'Crea, edita o bloquea accesos al sistema.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UsersPage()),
                );
              },
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'General',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.business_outlined,
            title: 'Datos de empresa',
            subtitle: 'Configura informacion comercial y datos generales.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CompanyProfilePage()),
              );
            },
          ),
          const SizedBox(height: 12),
          const SettingsTile(
            icon: Icons.picture_as_pdf_outlined,
            title: 'PDF y cotizaciones',
            subtitle: 'Ajusta opciones relacionadas al formato de salida.',
          ),
          const SizedBox(height: 12),
          const SettingsTile(
            icon: Icons.attach_money_outlined,
            title: 'Moneda e impuestos',
            subtitle: 'Define valores por defecto para cotizaciones.',
          ),
          const SizedBox(height: 12),
          const SettingsTile(
            icon: Icons.backup_outlined,
            title: 'Respaldo',
            subtitle: 'Administra futuras opciones de exportacion o respaldo.',
          ),
        ],
      ),
    );
  }
}
