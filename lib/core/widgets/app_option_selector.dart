import 'package:flutter/material.dart';

class AppOptionSelector extends StatelessWidget {
  const AppOptionSelector({
    super.key,
    required this.icon,
    required this.onTap,
    this.value,
    this.compact = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? value;
  final bool compact;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final selector = compact
        ? InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Ink(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Icon(
                icon,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        : InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      value ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.unfold_more_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          );

    if (tooltip == null || tooltip!.isEmpty) {
      return selector;
    }

    return Tooltip(message: tooltip!, child: selector);
  }
}
