// Топ-5 криптовалют с демо-ценами в рублях и OHLC-историей для свечных графиков.
import 'stocks_api.dart';

/// Котировка криптовалюты (символ, название, цена в RUB за 1 единицу).
class CryptoQuote {
  final String symbol;
  final String name;
  final double priceRub;

  const CryptoQuote({
    required this.symbol,
    required this.name,
    required this.priceRub,
  });
}

/// Топ-5 криптовалют с демо-ценами. В реальном приложении — запрос к CoinGecko/Binance и т.д.
class CryptoApi {
  static const _mockCrypto = [
    CryptoQuote(symbol: 'BTC', name: 'Bitcoin', priceRub: 6200000),
    CryptoQuote(symbol: 'ETH', name: 'Ethereum', priceRub: 380000),
    CryptoQuote(symbol: 'BNB', name: 'BNB', priceRub: 52000),
    CryptoQuote(symbol: 'XRP', name: 'Ripple', priceRub: 58),
    CryptoQuote(symbol: 'SOL', name: 'Solana', priceRub: 18500),
  ];

  /// Список топ-5 криптовалют с демо-ценами в рублях.
  static Future<List<CryptoQuote>> fetch() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockCrypto);
  }

  /// Демо-история OHLC для свечного графика (псевдо-случайные свечи, волатильность выше чем у акций).
  static Future<List<CandlePoint>> fetchHistory(CryptoQuote crypto, StockChartPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final now = DateTime.now();
    final int count;
    final Duration step;
    switch (period) {
      case StockChartPeriod.hour:
        count = 120;
        step = const Duration(seconds: 30);
        break;
      case StockChartPeriod.day:
        count = 96;
        step = const Duration(minutes: 15);
        break;
      case StockChartPeriod.week:
        count = 168;
        step = const Duration(hours: 1);
        break;
      case StockChartPeriod.month:
        count = 120;
        step = const Duration(hours: 6);
        break;
      case StockChartPeriod.year:
        count = 200;
        step = const Duration(hours: 43, minutes: 48);
        break;
      case StockChartPeriod.all:
        count = 300;
        step = const Duration(days: 30);
        break;
    }
    final seed = crypto.symbol.hashCode + period.index;
    final points = <CandlePoint>[];
    double close = crypto.priceRub;
    var t = now;
    for (var i = 0; i < count; i++) {
      final open = close;
      final variation = 0.04 * ((seed + i * 7) % 100) / 100 - 0.02;
      close = open * (1 + variation);
      final low = open < close ? open : close;
      final high = open > close ? open : close;
      final range = (high - low).clamp(0.001, double.infinity);
      final low2 = low - range * 0.4 * ((seed + i * 11) % 50) / 50;
      final high2 = high + range * 0.4 * ((seed + i * 13) % 50) / 50;
      points.insert(0, CandlePoint(
        time: t,
        open: open,
        high: high2,
        low: low2,
        close: close,
      ));
      t = t.subtract(step);
    }
    return points;
  }
}
