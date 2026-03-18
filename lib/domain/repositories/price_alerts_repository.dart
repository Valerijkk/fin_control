import '../../data/db.dart';
import '../models/price_alert.dart';

/// Репозиторий оповещений по курсу валют (таблица [price_alerts]).
class PriceAlertsRepository {
  final AppDatabase _db = AppDatabase();

  /// Все оповещения; [onlyPending] — только не сработавшие (notified = 0).
  Future<List<PriceAlert>> getAll({bool onlyPending = true}) async {
    final rows = await _db.getPriceAlertsRaw(onlyPending: onlyPending);
    return rows.map((r) => PriceAlert.fromMap(r)).toList();
  }

  /// Добавляет оповещение в БД.
  Future<void> add(PriceAlert alert) async {
    await _db.insertPriceAlertRaw(alert.toMap());
  }

  /// Отмечает оповещение как сработавшее (notified = 1).
  Future<void> markNotified(int id) async {
    await _db.markPriceAlertNotified(id);
  }

  /// Удаляет оповещение по [id].
  Future<void> delete(int id) async {
    await _db.deletePriceAlert(id);
  }

  /// Удаляет все оповещения (используется в тестах).
  Future<void> clear() async {
    final all = await getAll(onlyPending: false);
    for (final a in all) {
      await _db.deletePriceAlert(a.id);
    }
  }
}
