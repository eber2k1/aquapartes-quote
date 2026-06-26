import 'package:flutter/material.dart';

import '../../../../core/widgets/app_option_selector.dart';
import '../../../../core/widgets/app_search_field.dart';

class CatalogToolbar extends StatelessWidget {
  const CatalogToolbar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onViewTap,
    required this.onSortTap,
    required this.viewIcon,
    required this.viewTooltip,
    required this.sortIcon,
    required this.sortTooltip,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onViewTap;
  final VoidCallback onSortTap;
  final IconData viewIcon;
  final String viewTooltip;
  final IconData sortIcon;
  final String sortTooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppSearchField(
            controller: searchController,
            onChanged: onSearchChanged,
            hintText: 'Buscar producto',
          ),
        ),
        const SizedBox(width: 12),
        AppOptionSelector(
          icon: viewIcon,
          onTap: onViewTap,
          compact: true,
          tooltip: viewTooltip,
        ),
        const SizedBox(width: 8),
        AppOptionSelector(
          icon: sortIcon,
          onTap: onSortTap,
          compact: true,
          tooltip: sortTooltip,
        ),
      ],
    );
  }
}
