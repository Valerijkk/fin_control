// Хранение пользовательских категорий в SharedPreferences (дополнение к kDefaultCategories).
import 'package:shared_preferences/shared_preferences.dart';
import '../core/categories.dart';

/// Хранилище пользовательских категорий. При первом запуске возвращает [kDefaultCategories].
class CategoryStore {
  static const _key = 'user_categories_v1';

  /// Загружает список категорий. Если пусто — возвращает [kDefaultCategories].
  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list == null || list.isEmpty) return List<String>.from(kDefaultCategories);
    final clean = <String>{};
    for (final s in list) {
      final name = s.trim();
      if (name.isNotEmpty) clean.add(name);
    }
    return clean.toList();
  }

  /// Сохраняет полный список категорий в SharedPreferences.
  Future<void> save(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, categories);
  }

  /// Добавляет категорию [name], сохраняет и возвращает обновлённый список.
  Future<List<String>> add(String name) async {
    final list = await load();
    final n = name.trim();
    if (n.isEmpty) return list;
    if (!list.contains(n)) {
      list.add(n);
      await save(list);
    }
    return list;
  }
}
