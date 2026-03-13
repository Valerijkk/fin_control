// Репозиторий расходов/доходов: CRUD через AppDatabase (таблица expenses).
import '../../data/db.dart';
import '../models/expense.dart';

class ExpenseRepository {
  final AppDatabase _db = AppDatabase();

  /// Все записи, отсортированные по дате (новые сверху).
  Future<List<Expense>> getAll() async {
    final rows = await _db.getAllRaw();
    return rows.map((r) => Expense.fromMap(r)).toList(growable: false);
  }

  /// Добавляет запись в БД.
  Future<void> insert(Expense e) async {
    await _db.insertRaw(e.toMap());
  }

  /// Обновляет запись по [id].
  Future<void> update(String id, Expense e) async {
    await _db.updateRaw(id, e.toMap());
  }

  /// Удаляет запись по [id].
  Future<void> delete(String id) async {
    await _db.deleteById(id);
  }

  /// Удаляет все записи из таблицы expenses.
  Future<void> clear() async {
    await _db.deleteAll();
  }
}
