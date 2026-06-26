import 'package:flutter/material.dart';

class AppOptionItem<T> {
  const AppOptionItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

class AppOptionPickerSheet<T> extends StatelessWidget {
  const AppOptionPickerSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedValue,
  });

  final String title;
  final String subtitle;
  final List<AppOptionItem<T>> options;
  final T selectedValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ...options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: option.value == selectedValue
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).pop(option.value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: option.value == selectedValue
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            option.icon,
                            size: 20,
                            color: option.value == selectedValue
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option.label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: option.value == selectedValue
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (option.value == selectedValue)
                            Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
