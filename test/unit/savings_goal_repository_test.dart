// test/unit/savings_goal_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/domain/models/savings_goal.dart';
import 'package:fin_control/domain/repositories/savings_goal_repository.dart';

void main() {
  late SavingsGoalRepository repo;

  setUp(() async {
    repo = SavingsGoalRepository();
    await repo.clear();
  });

  group('SavingsGoalRepository', () {
    test('getAll returns empty initially', () async {
      final all = await repo.getAll();
      expect(all, isEmpty);
    });

    test('add creates goal', () async {
      await repo.add(SavingsGoal(
        id: 0,
        title: 'Отпуск',
        targetAmount: 100000,
        baseCurrency: 'RUB',
        currentAmount: 0,
        deadline: DateTime(2026, 12, 31),
        createdAt: DateTime.now(),
      ));
      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.title, 'Отпуск');
      expect(all.first.targetAmount, 100000);
      expect(all.first.currentAmount, 0);
    });

    test('updateCurrentAmount changes progress', () async {
      await repo.add(SavingsGoal(
        id: 0,
        title: 'Машина',
        targetAmount: 500000,
        baseCurrency: 'RUB',
        currentAmount: 0,
        createdAt: DateTime.now(),
      ));
      final all = await repo.getAll();
      final goal = all.last;
      await repo.updateCurrentAmount(goal.id, 25000);
      final updated = await repo.getAll();
      final updatedGoal = updated.firstWhere((g) => g.id == goal.id);
      expect(updatedGoal.currentAmount, 25000);
    });

    test('delete removes goal', () async {
      await repo.add(SavingsGoal(
        id: 0,
        title: 'Ноутбук',
        targetAmount: 80000,
        baseCurrency: 'RUB',
        currentAmount: 10000,
        createdAt: DateTime.now(),
      ));
      final before = await repo.getAll();
      final goal = before.last;
      await repo.delete(goal.id);
      final after = await repo.getAll();
      expect(after.where((g) => g.id == goal.id), isEmpty);
    });

    test('progressPercent calculates correctly', () {
      final goal = SavingsGoal(
        id: 1,
        title: 'Тест',
        targetAmount: 200,
        baseCurrency: 'RUB',
        currentAmount: 100,
        createdAt: DateTime.now(),
      );
      expect(goal.progressPercent, 50);
    });
  });
}
