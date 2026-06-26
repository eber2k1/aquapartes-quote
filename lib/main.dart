import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/services/app_notifications.dart';
import 'app/main_shell.dart';
import 'features/auth/auth_module.dart';
import 'features/auth/domain/entities/auth_session.dart';
import 'features/auth/presentation/pages/auth_login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _guestModeKey = 'guest_mode_enabled';
  static const _offlineModeKey = 'offline_mode_enabled';
  final _authRepository = getAuthRepository();
  bool _isDarkMode = false;
  bool _isOfflineMode = false;
  bool _isLoadingSession = true;
  bool _isGuestMode = false;
  AuthSession? _session;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  void _handleThemeModeChanged(bool isDarkMode) {
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  Future<void> _handleOfflineModeChanged(bool isOffline) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_offlineModeKey, isOffline);
    ApiClient.forceOfflineMode = isOffline;
    setState(() {
      _isOfflineMode = isOffline;
    });
  }

  Future<void> _loadSession() async {
    final preferences = await SharedPreferences.getInstance();
    final session = await _authRepository.loadSession();
    final isOffline = preferences.getBool(_offlineModeKey) ?? false;

    ApiClient.forceOfflineMode = isOffline;

    if (!mounted) return;

    setState(() {
      _session = session;
      _isGuestMode =
          session == null && preferences.getBool(_guestModeKey) == true;
      _isOfflineMode = isOffline;
      _isLoadingSession = false;
    });
  }

  Future<void> _setGuestMode(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_guestModeKey, enabled);
  }

  Future<void> _handleSignedIn(AuthSession session) async {
    await _setGuestMode(false);
    if (!mounted) return;

    setState(() {
      _session = session;
      _isGuestMode = false;
    });
  }

  Future<void> _handleContinueAsGuest() async {
    await _setGuestMode(true);
    if (!mounted) return;

    setState(() {
      _session = null;
      _isGuestMode = true;
    });
  }

  Future<void> _handleSignedOut() async {
    final wasGuestMode = _isGuestMode;
    if (_isGuestMode) {
      await _setGuestMode(false);
    } else {
      await _authRepository.logout();
      await _setGuestMode(false);
    }
    if (!mounted) return;

    setState(() {
      _session = null;
      _isGuestMode = false;
    });

    AppNotifications.showInfo(
      wasGuestMode ? 'Saliste del modo invitado.' : 'Sesión cerrada.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cotizador Aquapartes',
      scaffoldMessengerKey: AppNotifications.messengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 49, 132, 228),
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 49, 132, 228),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _isLoadingSession
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : (_session == null && !_isGuestMode
                ? AuthLoginPage(
                    onSignedIn: _handleSignedIn,
                    onContinueAsGuest: _handleContinueAsGuest,
                  )
                : MainShell(
                    isGuestMode: _isGuestMode,
                    isDarkMode: _isDarkMode,
                    isOfflineMode: _isOfflineMode,
                    onThemeModeChanged: _handleThemeModeChanged,
                    onOfflineModeChanged: _handleOfflineModeChanged,
                    onSignOut: _handleSignedOut,
                  )),
    );
  }
}
