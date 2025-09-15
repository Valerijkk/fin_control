import '../../data/db.dart';
import '../models/expense.dart';

class ExpenseRepository {
  final AppDatabase _db = AppDatabase();

  Future<List<Expense>> getAll() async {
    final rows = await _db.getAllRaw();
    return rows.map((r) {
      return Expense(
        id: (r['id'] as String),
        title: (r['title'] as String),
        amount: (r['amount'] as num).toDouble(),
        category: (r['category'] as String),
        date: DateTime.fromMillisecondsSinceEpoch((r['date'] as int)),
        isIncome: ((r['is_income'] as int) == 1),
        imagePath: r['image_path'] as String?,
      );
    }).toList(growable: false);
  }

  Future<void> insert(Expense e) async {
    await _db.insertRaw({
      'id': e.id,
      'title': e.title,
      'amount': e.amount,
      'category': e.category,
      'date': e.date.millisecondsSinceEpoch,
      'is_income': e.isIncome ? 1 : 0,
      'image_path': e.imagePath,
    });
  }

  Future<void> update(String id, Expense e) async {
    await _db.updateRaw(id, {
      'id': e.id,
      'title': e.title,
      'amount': e.amount,
      'category': e.category,
      'date': e.date.millisecondsSinceEpoch,
      'is_income': e.isIncome ? 1 : 0,
      'image_path': e.imagePath,
    });
  }

  Future<void> delete(String id) async {
    await _db.deleteById(id);
  }

  Future<void> clear() async {
    await _db.deleteAll();
  }
}
