// test/unit/categories_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/core/categories.dart';

void main() {
  group('kDefaultCategories', () {
    test('содержит ожидаемые категории', () {
      expect(kDefaultCategories, contains('Еда'));
      expect(kDefaultCategories, contains('Транспорт'));
      expect(kDefaultCategories, contains('Другое'));
      expect(kDefaultCategories.length, greaterThanOrEqualTo(5));
    });
  });

  group('categoryIcon', () {
    test('возвращает иконку для известной категории', () {
      expect(categoryIcon('Еда'), Icons.lunch_dining);
      expect(categoryIcon('Транспорт'), Icons.directions_bus_filled);
      expect(categoryIcon('Дом'), Icons.home_outlined);
      expect(categoryIcon('Другое'), Icons.category_outlined);
    });
    test('неизвестная категория возвращает category_outlined', () {
      expect(categoryIcon('Неизвестная'), Icons.category_outlined);
    });
  });

  group('categoryColor', () {
    test('возвращает цвет для известной категории', () {
      expect(categoryColor('Еда'), Colors.orange);
      expect(categoryColor('Транспорт'), Colors.blue);
      expect(categoryColor('Другое'), Colors.grey);
    });
    test('неизвестная категория возвращает grey', () {
      expect(categoryColor('Кастом'), Colors.grey);
    });
  });
}
