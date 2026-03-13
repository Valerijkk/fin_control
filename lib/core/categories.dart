import 'package:flutter/material.dart';

/// Дефолтный набор категорий расходов/доходов (используется при первом старте приложения).
const kDefaultCategories = ['Еда', 'Транспорт', 'Дом', 'Досуг', 'Портфель', 'Другое'];

/// Возвращает иконку Material для категории [c] (для списков и фильтров).
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
    case 'Портфель':
      return Icons.account_balance_wallet_outlined;
    default:
      return Icons.category_outlined;
  }
}

/// Возвращает цвет для категории [c] (полоски в статистике, чипы и т.д.).
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
    case 'Портфель':
      return Colors.indigo;
    default:
      return Colors.grey;
  }
}
