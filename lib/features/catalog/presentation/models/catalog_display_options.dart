import 'package:flutter/material.dart';

enum CatalogViewMode { loose, brand, category }

enum CatalogSortMode { nameAsc, nameDesc, priceAsc, priceDesc }

class CatalogDisplayOptions {
  const CatalogDisplayOptions._();

  static String viewModeLabel(CatalogViewMode mode) {
    switch (mode) {
      case CatalogViewMode.loose:
        return 'Sin agrupar';
      case CatalogViewMode.brand:
        return 'Marca';
      case CatalogViewMode.category:
        return 'Categoria';
    }
  }

  static IconData viewModeIcon(CatalogViewMode mode) {
    switch (mode) {
      case CatalogViewMode.loose:
        return Icons.view_agenda_outlined;
      case CatalogViewMode.brand:
        return Icons.workspace_premium_outlined;
      case CatalogViewMode.category:
        return Icons.category_outlined;
    }
  }

  static String sortModeLabel(CatalogSortMode mode) {
    switch (mode) {
      case CatalogSortMode.nameAsc:
        return 'Nombre A-Z';
      case CatalogSortMode.nameDesc:
        return 'Nombre Z-A';
      case CatalogSortMode.priceAsc:
        return 'Precio menor';
      case CatalogSortMode.priceDesc:
        return 'Precio mayor';
    }
  }

  static IconData sortModeIcon(CatalogSortMode mode) {
    switch (mode) {
      case CatalogSortMode.nameAsc:
      case CatalogSortMode.nameDesc:
        return Icons.sort_by_alpha_outlined;
      case CatalogSortMode.priceAsc:
        return Icons.south_rounded;
      case CatalogSortMode.priceDesc:
        return Icons.north_rounded;
    }
  }
}
