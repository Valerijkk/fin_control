import 'package:shared_preferences/shared_preferences.dart';
import '../core/categories.dart';

class CategoryStore {
  static const _key = 'user_categories_v1';

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list == null || list.isEmpty) return List<String>.from(kDefaultCategories);
    // чистим от пустых/дубликатов
    final clean = <String>{};
    for (final s in list) {
      final name = s.trim();
      if (name.isNotEmpty) clean.add(name);
    }
    return clean.toList();
  }

  Future<void> save(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, categories);
  }

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
