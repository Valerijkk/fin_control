import 'package:flutter/foundation.dart';
import '../domain/models/expense.dart';
import '../domain/repositories/expense_repository.dart';
import '../data/category_store.dart';
import '../core/categories.dart';

class AppState extends ChangeNotifier {
  final ExpenseRepository _repo = ExpenseRepository();
  final CategoryStore _catStore = CategoryStore();

  final List<Expense> _items = [];
  List<String> _categories = List<String>.from(kDefaultCategories);

  List<Expense> get items => List.unmodifiable(_items);
  List<String> get categories => List.unmodifiable(_categories);

  Expense? _lastRemoved;
  int? _lastIndex;

  Future<void> load() async {
    _items
      ..clear()
      ..addAll(await _repo.getAll());

    _categories = await _catStore.load();
    notifyListeners();
  }

  Future<void> add(Expense e) async {
    _items.insert(0, e);
    notifyListeners();
    await _repo.insert(e);
  }

  Future<void> update(String id, Expense e) async {
    final i = _items.indexWhere((x) => x.id == id);
    if (i == -1) return;
    _items[i] = e;
    notifyListeners();
    await _repo.update(id, e);
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _items.length) return;
    _lastRemoved = _items.removeAt(index);
    _lastIndex = index;
    notifyListeners();
    if (_lastRemoved != null) {
      await _repo.delete(_lastRemoved!.id);
    }
  }

  Future<bool> undoLastRemove() async {
    if (_lastRemoved == null || _lastIndex == null) return false;
    final i = (_lastIndex!).clamp(0, _items.length);
    final e = _lastRemoved!;
    _items.insert(i, e);
    _lastRemoved = null;
    _lastIndex = null;
    notifyListeners();
    await _repo.insert(e);
    return true;
  }

  Future<void> clearAll() async {
    _items.clear();
    notifyListeners();
    await _repo.clear();
  }

  // ===== Категории =====

  Future<String?> addCategory(String name) async {
    final n = name.trim();
    if (n.isEmpty) return null;
    if (_categories.contains(n)) return n;
    _categories = await _catStore.add(n);
    notifyListeners();
    return n;
  }
}
