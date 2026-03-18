// test/unit/limit_orders_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/domain/models/limit_order.dart';
import 'package:fin_control/domain/repositories/limit_orders_repository.dart';

void main() {
  late LimitOrdersRepository repo;

  setUp(() async {
    repo = LimitOrdersRepository();
    await repo.clear();
  });

  group('LimitOrdersRepository', () {
    test('getAll returns empty list initially', () async {
      final all = await repo.getAll();
      expect(all, isEmpty);
    });

    test('add and getPending returns pending orders', () async {
      await repo.add(LimitOrder(
        id: 0,
        currencyFrom: 'RUB',
        currencyTo: 'USD',
        amountFrom: 1000,
        targetRate: 0.012,
        isAbove: true,
        createdAt: DateTime.now(),
      ));
      final pending = await repo.getPending();
      expect(pending.length, 1);
      expect(pending.first.currencyFrom, 'RUB');
      expect(pending.first.status, 'pending');
    });

    test('setStatus changes order status', () async {
      await repo.add(LimitOrder(
        id: 0,
        currencyFrom: 'RUB',
        currencyTo: 'EUR',
        amountFrom: 500,
        targetRate: 0.01,
        isAbove: false,
        createdAt: DateTime.now(),
      ));
      final all = await repo.getAll();
      final order = all.last;
      await repo.setStatus(order.id, 'done');
      final updated = await repo.getAll();
      final done = updated.firstWhere((o) => o.id == order.id);
      expect(done.status, 'done');
    });

    test('getPending excludes done and cancelled', () async {
      await repo.add(LimitOrder(
        id: 0,
        currencyFrom: 'RUB',
        currencyTo: 'GBP',
        amountFrom: 200,
        targetRate: 0.009,
        isAbove: true,
        createdAt: DateTime.now(),
      ));
      final all = await repo.getAll();
      final order = all.last;
      await repo.setStatus(order.id, 'cancelled');
      final pending = await repo.getPending();
      final cancelled = pending.where((o) => o.id == order.id);
      expect(cancelled, isEmpty);
    });

    test('delete removes order', () async {
      await repo.add(LimitOrder(
        id: 0,
        currencyFrom: 'RUB',
        currencyTo: 'CHF',
        amountFrom: 300,
        targetRate: 0.011,
        isAbove: true,
        createdAt: DateTime.now(),
      ));
      final before = await repo.getAll();
      final order = before.last;
      await repo.delete(order.id);
      final after = await repo.getAll();
      expect(after.where((o) => o.id == order.id), isEmpty);
    });
  });
}
