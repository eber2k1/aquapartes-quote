import 'package:flutter/material.dart';

class AppConfirmationDialog extends StatelessWidget {
  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText = 'Cancelar',
    this.confirmText = 'Confirmar',
    this.isDestructive = false,
  });

  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final bool isDestructive;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String content,
    String cancelText = 'Cancelar',
    String confirmText = 'Confirmar',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AppConfirmationDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        confirmText: confirmText,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        if (isDestructive)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(confirmText),
          )
        else
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
      ],
    );
  }
}
