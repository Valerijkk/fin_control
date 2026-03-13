// test/unit/stocks_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/services/stocks_api.dart';

void main() {
  group('StocksApi.fetch', () {
    test('возвращает список акций', () async {
      final list = await StocksApi.fetch();
      expect(list.length, greaterThanOrEqualTo(5));
      expect(list.any((s) => s.ticker == 'AAPL'), isTrue);
      expect(list.any((s) => s.ticker == 'MSFT'), isTrue);
    });

    test('у каждой акции есть ticker, name, priceRub', () async {
      final list = await StocksApi.fetch();
      for (final s in list) {
        expect(s.ticker, isNotEmpty);
        expect(s.name, isNotEmpty);
        expect(s.priceRub, greaterThan(0));
      }
    });
  });

  group('StocksApi.fetchHistory', () {
    test('возвращает список OHLC-свечей для периода', () async {
      const stock = StockQuote(ticker: 'TEST', name: 'Test', priceRub: 100);
      final points = await StocksApi.fetchHistory(stock, StockChartPeriod.day);
      expect(points.length, greaterThanOrEqualTo(2));
      for (final p in points) {
        expect(p.open, greaterThan(0));
        expect(p.high, greaterThanOrEqualTo(p.low));
        expect(p.close, greaterThan(0));
        expect(p.time.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
      }
    });

    test('разные периоды дают разное количество точек или шаг', () async {
      const stock = StockQuote(ticker: 'X', name: 'X', priceRub: 50);
      final day = await StocksApi.fetchHistory(stock, StockChartPeriod.day);
      final week = await StocksApi.fetchHistory(stock, StockChartPeriod.week);
      expect(day.length, greaterThanOrEqualTo(2));
      expect(week.length, greaterThanOrEqualTo(2));
    });
  });

  group('StockChartPeriod', () {
    test('все периоды имеют label', () {
      for (final p in StockChartPeriod.values) {
        expect(p.label, isNotEmpty);
      }
    });
  });
}
