import 'package:flutter/material.dart';

class AppNotifications {
  AppNotifications._();

  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message) {
    _show(
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: const Color(0xFF1F7A4C),
    );
  }

  static void showInfo(String message) {
    _show(
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: const Color(0xFF2F5D9F),
    );
  }

  static void showDelete(String message) {
    _show(
      message: message,
      icon: Icons.delete_rounded,
      backgroundColor: const Color(0xFFC62828),
    );
  }

  static void _show({
    required String message,
    required IconData icon,
    required Color backgroundColor,
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
