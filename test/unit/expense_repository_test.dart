// test/unit/expense_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/domain/models/expense.dart';
import 'package:fin_control/domain/repositories/expense_repository.dart';

void main() {
  late ExpenseRepository repo;

  setUp(() async {
    repo = ExpenseRepository();
    await repo.clear();
  });

  group('ExpenseRepository', () {
    test('getAll изначально пустой', () async {
      final list = await repo.getAll();
      expect(list, isEmpty);
    });

    test('insert и getAll возвращают запись', () async {
      final e = Expense(
        id: 'test-1',
        title: 'Тест',
        amount: 100,
        category: 'Другое',
        date: DateTime(2025, 1, 15),
        isIncome: false,
      );
      await repo.insert(e);
      final list = await repo.getAll();
      expect(list.length, 1);
      expect(list.first.id, 'test-1');
      expect(list.first.title, 'Тест');
      expect(list.first.amount, 100);
      expect(list.first.category, 'Другое');
      expect(list.first.isIncome, false);
    });

    test('update меняет запись', () async {
      final e = Expense(
        id: 'test-upd',
        title: 'До',
        amount: 50,
        category: 'Еда',
        date: DateTime(2025, 2, 1),
        isIncome: false,
      );
      await repo.insert(e);
      final updated = e.copyWith(title: 'После', amount: 75);
      await repo.update('test-upd', updated);
      final list = await repo.getAll();
      expect(list.first.title, 'После');
      expect(list.first.amount, 75);
    });

    test('delete удаляет запись', () async {
      final e = Expense(
        id: 'test-del',
        title: 'На удаление',
        amount: 1,
        category: 'Другое',
        date: DateTime.now(),
        isIncome: false,
      );
      await repo.insert(e);
      expect((await repo.getAll()).length, 1);
      await repo.delete('test-del');
      expect((await repo.getAll()).length, 0);
    });

    test('clear очищает все записи', () async {
      await repo.insert(Expense(
        id: 'c1',
        title: 'A',
        amount: 1,
        category: 'Другое',
        date: DateTime.now(),
        isIncome: false,
      ));
      await repo.insert(Expense(
        id: 'c2',
        title: 'B',
        amount: 2,
        category: 'Другое',
        date: DateTime.now(),
        isIncome: false,
      ));
      expect((await repo.getAll()).length, 2);
      await repo.clear();
      expect((await repo.getAll()).length, 0);
    });
  });
}
