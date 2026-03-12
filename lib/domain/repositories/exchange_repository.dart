import '../../data/db.dart';
import '../models/exchange_operation.dart';

class ExchangeRepository {
  final AppDatabase _db = AppDatabase();

  Future<List<ExchangeOperation>> getAll() async {
    final rows = await _db.getExchangeOperationsRaw();
    return rows.map((r) => ExchangeOperation.fromMap(r)).toList();
  }

  Future<void> add(ExchangeOperation op) async {
    await _db.insertExchangeOperationRaw(op.toMap());
  }
}
