// test/unit/price_alerts_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/domain/models/price_alert.dart';
import 'package:fin_control/domain/repositories/price_alerts_repository.dart';

void main() {
  late PriceAlertsRepository repo;

  setUp(() async {
    repo = PriceAlertsRepository();
    await repo.clear();
  });

  group('PriceAlertsRepository', () {
    test('getAll returns empty initially', () async {
      final all = await repo.getAll();
      expect(all, isEmpty);
    });

    test('add creates alert and getAll returns it', () async {
      await repo.add(PriceAlert(
        id: 0,
        currencyFrom: 'RUB',
        currencyTo: 'USD',
        targetRate: 0.012,
        isAbove: true,
        createdAt: DateTime.now(),
      ));
      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.currencyFrom, 'RUB');
      expect(all.first.currencyTo, 'USD');
      expect(all.first.notified, false);
    });

    test('markNotified sets notified flag', () async {
      await repo.add(PriceAlert(
        id: 0,
        currencyFrom: 'EUR',
        currencyTo: 'USD',
        targetRate: 1.1,
        isAbove: true,
        createdAt: DateTime.now(),
      ));
      final all = await repo.getAll();
      final alert = all.last;
      await repo.markNotified(alert.id);
      final updated = await repo.getAll(onlyPending: false);
      final notified = updated.firstWhere((a) => a.id == alert.id);
      expect(notified.notified, true);
    });

    test('getAll onlyPending filters notified alerts', () async {
      await repo.add(PriceAlert(
        id: 0,
        currencyFrom: 'RUB',
        currencyTo: 'GBP',
        targetRate: 0.009,
        isAbove: false,
        createdAt: DateTime.now(),
      ));
      final all = await repo.getAll();
      final alert = all.last;
      await repo.markNotified(alert.id);
      final pending = await repo.getAll(onlyPending: true);
      expect(pending.where((a) => a.id == alert.id), isEmpty);
    });

    test('delete removes alert', () async {
      await repo.add(PriceAlert(
        id: 0,
        currencyFrom: 'RUB',
        currencyTo: 'CHF',
        targetRate: 0.011,
        isAbove: true,
        createdAt: DateTime.now(),
      ));
      final before = await repo.getAll();
      final alert = before.last;
      await repo.delete(alert.id);
      final after = await repo.getAll();
      expect(after.where((a) => a.id == alert.id), isEmpty);
    });
  });
}
