// test/unit/crypto_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/services/crypto_api.dart';
import 'package:fin_control/services/stocks_api.dart';

void main() {
  group('CryptoApi.fetch', () {
    test('возвращает список криптовалют', () async {
      final list = await CryptoApi.fetch();
      expect(list.length, greaterThanOrEqualTo(5));
      expect(list.any((c) => c.symbol == 'BTC'), isTrue);
      expect(list.any((c) => c.symbol == 'ETH'), isTrue);
    });

    test('у каждой крипты есть symbol, name, priceRub', () async {
      final list = await CryptoApi.fetch();
      for (final c in list) {
        expect(c.symbol, isNotEmpty);
        expect(c.name, isNotEmpty);
        expect(c.priceRub, greaterThan(0));
      }
    });
  });

  group('CryptoApi.fetchHistory', () {
    test('возвращает список OHLC-свечей для периода', () async {
      const crypto = CryptoQuote(symbol: 'TEST', name: 'Test', priceRub: 1000);
      final points = await CryptoApi.fetchHistory(crypto, StockChartPeriod.day);
      expect(points.length, greaterThanOrEqualTo(2));
      for (final p in points) {
        expect(p.open, greaterThan(0));
        expect(p.high, greaterThanOrEqualTo(p.low));
        expect(p.close, greaterThan(0));
      }
    });

    test('разные периоды дают разное количество точек', () async {
      const crypto = CryptoQuote(symbol: 'X', name: 'X', priceRub: 500);
      final day = await CryptoApi.fetchHistory(crypto, StockChartPeriod.day);
      final week = await CryptoApi.fetchHistory(crypto, StockChartPeriod.week);
      expect(day.length, greaterThanOrEqualTo(2));
      expect(week.length, greaterThanOrEqualTo(2));
    });
  });
}
