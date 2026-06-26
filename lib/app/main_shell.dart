import 'package:flutter/material.dart';

import '../features/catalog/presentation/pages/catalog_page.dart';
import '../features/customers/presentation/pages/customers_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/quote/presentation/pages/quote_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import 'widgets/app_app_bar.dart';
import 'widgets/app_navigation_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.isGuestMode,
    required this.isDarkMode,
    required this.isOfflineMode,
    required this.onThemeModeChanged,
    required this.onOfflineModeChanged,
    required this.onSignOut,
  });

  final bool isGuestMode;
  final bool isDarkMode;
  final bool isOfflineMode;
  final ValueChanged<bool> onThemeModeChanged;
  final ValueChanged<bool> onOfflineModeChanged;
  final Future<void> Function() onSignOut;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    QuotePage(),
    CatalogPage(),
    CustomersPage(),
    ReportsPage(),
  ];

  void _openProfilePage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          isGuestMode: widget.isGuestMode,
          onSignOut: widget.onSignOut,
        ),
      ),
    );
  }

  void _openSettingsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          isGuestMode: widget.isGuestMode,
          isDarkMode: widget.isDarkMode,
          isOfflineMode: widget.isOfflineMode,
          onThemeModeChanged: widget.onThemeModeChanged,
          onOfflineModeChanged: widget.onOfflineModeChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        onUserPressed: _openProfilePage,
        onSettingsPressed: _openSettingsPage,
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
