// test/unit/portfolio_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/domain/models/portfolio_holding.dart';
import 'package:fin_control/domain/models/portfolio_transaction.dart';
import 'package:fin_control/domain/repositories/portfolio_repository.dart';

void main() {
  late PortfolioRepository repo;

  setUp(() {
    repo = PortfolioRepository();
  });

  group('PortfolioRepository', () {
    test('getBalance возвращает значение по умолчанию при первом обращении', () async {
      final balance = await repo.getBalance();
      expect(balance, greaterThan(0));
      expect(balance, 100000.0);
    });

    test('setBalance и getBalance сохраняют баланс', () async {
      await repo.setBalance(50000);
      expect(await repo.getBalance(), 50000);
      await repo.setBalance(75000);
      expect(await repo.getBalance(), 75000);
    });

    test('getBaseCurrency возвращает RUB по умолчанию', () async {
      expect(await repo.getBaseCurrency(), 'RUB');
    });

    test('getHoldings возвращает список', () async {
      final list = await repo.getHoldings();
      expect(list, isA<List<PortfolioHolding>>());
    });

    test('saveOrUpdateHolding сохраняет позицию, getHoldings содержит её', () async {
      final holding = PortfolioHolding(
        id: 0,
        currency: 'TST',
        amount: 10,
        avgRate: 90,
        updatedAt: DateTime.now(),
      );
      await repo.saveOrUpdateHolding(holding);
      final list = await repo.getHoldings();
      expect(list.any((h) => h.currency == 'TST' && h.amount == 10), isTrue);
      final found = list.firstWhere((h) => h.currency == 'TST');
      expect(found.avgRate, 90);
      await repo.deleteHolding('TST');
    });

    test('addTransaction сохраняет сделку, getTransactions содержит её', () async {
      final tx = PortfolioTransaction(
        id: 0,
        createdAt: DateTime.now(),
        type: 'buy',
        currency: 'TST',
        amount: 5,
        rate: 95,
        totalBase: 475,
      );
      await repo.addTransaction(tx);
      final list = await repo.getTransactions();
      expect(list.any((t) => t.currency == 'TST' && t.totalBase == 475), isTrue);
    });
  });
}
