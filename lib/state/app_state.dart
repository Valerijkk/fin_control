import 'package:flutter/foundation.dart';
import '../domain/models/expense.dart';
import '../domain/repositories/expense_repository.dart';
import '../data/category_store.dart';
import '../core/categories.dart';

/// Глобальное состояние приложения: список расходов/доходов, категории, отмена последнего удаления.
/// Уведомляет слушателей через [ChangeNotifier]; данные хранятся в [ExpenseRepository] и [CategoryStore].
class AppState extends ChangeNotifier {
  final ExpenseRepository _repo = ExpenseRepository();
  final CategoryStore _catStore = CategoryStore();

  final List<Expense> _items = [];
  List<String> _categories = List<String>.from(kDefaultCategories);

  /// Текущий список записей (расходы и доходы). Неизменяемая копия.
  List<Expense> get items => List.unmodifiable(_items);
  /// Список категорий (дефолтные + добавленные пользователем).
  List<String> get categories => List.unmodifiable(_categories);

  Expense? _lastRemoved;
  int? _lastIndex;

  /// Загружает записи и категории из БД и уведомляет слушателей.
  Future<void> load() async {
    _items
      ..clear()
      ..addAll(await _repo.getAll());

    _categories = await _catStore.load();
    notifyListeners();
  }

  /// Добавляет запись в начало списка и сохраняет в БД.
  Future<void> add(Expense e) async {
    _items.insert(0, e);
    notifyListeners();
    await _repo.insert(e);
  }

  /// Обновляет запись по [id] в списке и в БД.
  Future<void> update(String id, Expense e) async {
    final i = _items.indexWhere((x) => x.id == id);
    if (i == -1) return;
    _items[i] = e;
    notifyListeners();
    await _repo.update(id, e);
  }

  /// Удаляет запись по индексу из списка и БД. Сохраняет её для возможной отмены ([undoLastRemove]).
  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _items.length) return;
    _lastRemoved = _items.removeAt(index);
    _lastIndex = index;
    notifyListeners();
    if (_lastRemoved != null) {
      await _repo.delete(_lastRemoved!.id);
    }
  }

  /// Восстанавливает последнюю удалённую запись (если была).
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

  /// Очищает весь список и БД записей.
  Future<void> clearAll() async {
    _items.clear();
    notifyListeners();
    await _repo.clear();
  }

  // ===== Категории =====

  /// Добавляет пользовательскую категорию [name]. Возвращает имя при успехе, иначе null.
  Future<String?> addCategory(String name) async {
    final n = name.trim();
    if (n.isEmpty) return null;
    if (_categories.contains(n)) return n;
    _categories = await _catStore.add(n);
    notifyListeners();
    return n;
  }
}
