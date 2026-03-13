// test/unit/exchange_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/domain/models/exchange_operation.dart';
import 'package:fin_control/domain/repositories/exchange_repository.dart';

void main() {
  late ExchangeRepository repo;

  setUp(() {
    repo = ExchangeRepository();
  });

  group('ExchangeRepository', () {
    test('getAll возвращает список', () async {
      final list = await repo.getAll();
      expect(list, isA<List<ExchangeOperation>>());
    });

    test('add сохраняет операцию, getAll содержит её', () async {
      final before = await repo.getAll();
      final op = ExchangeOperation(
        id: 0,
        createdAt: DateTime(2025, 3, 1, 12, 0),
        amountFrom: 1000,
        currencyFrom: 'RUB',
        amountTo: 12.5,
        currencyTo: 'USD',
        rateUsed: 80,
      );
      await repo.add(op);
      final list = await repo.getAll();
      expect(list.length, greaterThan(before.length));
      final added = list.firstWhere(
        (o) => o.amountFrom == 1000 && o.currencyFrom == 'RUB' && o.currencyTo == 'USD',
        orElse: () => throw StateError('not found'),
      );
      expect(added.amountTo, 12.5);
      expect(added.rateUsed, 80);
    });
  });
}
