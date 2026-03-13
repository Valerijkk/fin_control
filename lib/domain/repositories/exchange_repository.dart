// Репозиторий операций обмена валют: чтение и добавление в таблицу exchange_operations.
import '../../data/db.dart';
import '../models/exchange_operation.dart';

class ExchangeRepository {
  final AppDatabase _db = AppDatabase();

  /// Все операции обмена, отсортированные по дате (новые сверху).
  Future<List<ExchangeOperation>> getAll() async {
    final rows = await _db.getExchangeOperationsRaw();
    return rows.map((r) => ExchangeOperation.fromMap(r)).toList();
  }

  /// Сохраняет операцию обмена в БД.
  Future<void> add(ExchangeOperation op) async {
    await _db.insertExchangeOperationRaw(op.toMap());
  }
}
