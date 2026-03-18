import '../../data/db.dart';
import '../models/savings_goal.dart';

/// Репозиторий целей накопления (таблица [savings_goals]).
class SavingsGoalRepository {
  final AppDatabase _db = AppDatabase();

  /// Все цели, сортировка по дате создания (новые сверху).
  Future<List<SavingsGoal>> getAll() async {
    final rows = await _db.getSavingsGoalsRaw();
    return rows.map((r) => SavingsGoal.fromMap(r)).toList();
  }

  /// Добавляет цель в БД. После вставки id в объекте [goal] не обновляется — для обновления загрузите список заново через [getAll].
  Future<void> add(SavingsGoal goal) async {
    await _db.insertSavingsGoalRaw(goal.toMap());
  }

  /// Обновляет только текущую сумму по цели [id].
  Future<void> updateCurrentAmount(int id, double currentAmount) async {
    await _db.updateSavingsGoalRaw(id, {'current_amount': currentAmount});
  }

  /// Полное обновление цели (по [goal.id]); целесообразно для целей, загруженных из [getAll].
  Future<void> update(SavingsGoal goal) async {
    await _db.updateSavingsGoalRaw(goal.id, goal.toMap());
  }

  /// Удаляет цель по [id].
  Future<void> delete(int id) async {
    await _db.deleteSavingsGoal(id);
  }

  /// Удаляет все цели (используется в тестах).
  Future<void> clear() async {
    final all = await getAll();
    for (final g in all) {
      await _db.deleteSavingsGoal(g.id);
    }
  }
}
