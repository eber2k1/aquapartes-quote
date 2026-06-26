import 'package:flutter/material.dart';

class AppNavigationItem {
  const AppNavigationItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
}

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.destinations = defaultDestinations,
  });

  static const List<AppNavigationItem> defaultDestinations = [
    AppNavigationItem(
      label: 'Cotizar',
      icon: Icons.request_quote_outlined,
      selectedIcon: Icons.request_quote,
    ),
    AppNavigationItem(
      label: 'Catalogo',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
    ),
    AppNavigationItem(
      label: 'Clientes',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
    ),
    AppNavigationItem(
      label: 'Informes',
      icon: Icons.assessment_outlined,
      selectedIcon: Icons.assessment,
    ),
  ];

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppNavigationItem> destinations;

  @override
  Widget build(BuildContext context) {
    if (destinations.isEmpty) {
      return const SizedBox.shrink();
    }

    final safeIndex = selectedIndex.clamp(0, destinations.length - 1);

    return NavigationBar(
      selectedIndex: safeIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations
          .map(
            (destination) => NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: destination.selectedIcon != null
                  ? Icon(destination.selectedIcon)
                  : null,
              label: destination.label,
            ),
          )
          .toList(),
    );
  }
}
