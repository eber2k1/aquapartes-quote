import 'package:flutter/material.dart';

enum CustomerSortMode { nameAsc, nameDesc }

class CustomerDisplayOptions {
  const CustomerDisplayOptions._();

  static String sortModeLabel(CustomerSortMode mode) {
    switch (mode) {
      case CustomerSortMode.nameAsc:
        return 'Nombre A-Z';
      case CustomerSortMode.nameDesc:
        return 'Nombre Z-A';
    }
  }

  static IconData sortModeIcon(CustomerSortMode mode) {
    return Icons.sort_by_alpha_outlined;
  }
}
