import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.clipBehavior,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Clip? clipBehavior;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return Card(
      elevation: 0,
      color: color,
      clipBehavior: clipBehavior,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(128),
        ),
      ),
      child: content,
    );
  }
}
