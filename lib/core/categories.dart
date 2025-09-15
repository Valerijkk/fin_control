import 'package:flutter/material.dart';

/// Дефолтный набор (используется при первом старте)
const kDefaultCategories = ['Еда', 'Транспорт', 'Дом', 'Досуг', 'Другое'];

IconData categoryIcon(String c) {
  switch (c) {
    case 'Еда':
      return Icons.lunch_dining;
    case 'Транспорт':
      return Icons.directions_bus_filled;
    case 'Дом':
      return Icons.home_outlined;
    case 'Досуг':
      return Icons.emoji_events_outlined;
    default:
      return Icons.category_outlined;
  }
}

Color categoryColor(String c) {
  switch (c) {
    case 'Еда':
      return Colors.orange;
    case 'Транспорт':
      return Colors.blue;
    case 'Дом':
      return Colors.teal;
    case 'Досуг':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}
