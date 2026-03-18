import '../../data/db.dart';
import '../models/limit_order.dart';

/// Репозиторий отложенных обменов (таблица [limit_orders]).
class LimitOrdersRepository {
  final AppDatabase _db = AppDatabase();

  /// Только ордера со статусом pending.
  Future<List<LimitOrder>> getPending() async {
    final rows = await _db.getLimitOrdersRaw(status: 'pending');
    return rows.map((r) => LimitOrder.fromMap(r)).toList();
  }

  /// Все ордера (любой статус), сортировка по дате (новые сверху).
  Future<List<LimitOrder>> getAll() async {
    final rows = await _db.getLimitOrdersRaw();
    return rows.map((r) => LimitOrder.fromMap(r)).toList();
  }

  /// Добавляет отложенный ордер в БД.
  Future<void> add(LimitOrder order) async {
    await _db.insertLimitOrderRaw(order.toMap());
  }

  /// Обновляет статус ордера (pending | done | cancelled).
  Future<void> setStatus(int id, String status) async {
    await _db.updateLimitOrderStatus(id, status);
  }

  /// Удаляет ордер по [id].
  Future<void> delete(int id) async {
    await _db.deleteLimitOrder(id);
  }

  /// Удаляет все ордера (используется в тестах).
  Future<void> clear() async {
    final all = await getAll();
    for (final o in all) {
      await _db.deleteLimitOrder(o.id);
    }
  }
}
