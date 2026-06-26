import 'package:flutter/material.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          title: Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 56,
            color: theme.colorScheme.outlineVariant.withAlpha(76),
          ),
      ],
    );
  }
}
