import 'package:flutter/material.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({super.key, this.onUserPressed, this.onSettingsPressed});

  final VoidCallback? onUserPressed;
  final VoidCallback? onSettingsPressed;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aquaColor = theme.brightness == Brightness.dark
        ? const Color(0xFF4DD4FF)
        : const Color(0xFF00A6D6);
    final partesColor = theme.brightness == Brightness.dark
        ? const Color(0xFFE3ECFF)
        : const Color(0xFF1D2A44);

    return AppBar(
      toolbarHeight: preferredSize.height,
      titleSpacing: 16,
      title: Row(
        children: [
          RichText(
            text: TextSpan(
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
              children: [
                TextSpan(
                  text: 'AQUA',
                  style: TextStyle(color: aquaColor),
                ),
                TextSpan(
                  text: 'PARTES',
                  style: TextStyle(color: partesColor),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onUserPressed ?? () {},
          icon: const Icon(Icons.person_outline),
          tooltip: 'Usuario',
        ),
        IconButton(
          onPressed: onSettingsPressed ?? () {},
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Ajustes',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
