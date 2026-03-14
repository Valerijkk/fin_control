// API акций (демо-данные). Все вызовы асинхронны (Future), UI не блокируется;
// при переходе на реальный сетевой API сохранять async/await и не выполнять тяжёлое на main isolate.

/// Одна свеча OHLC (open, high, low, close) для свечного графика.
class CandlePoint {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;

  const CandlePoint({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}

/// Период графика.
enum StockChartPeriod {
  hour('1Ч'),
  day('1Д'),
  week('1Н'),
  month('1М'),
  year('1Г'),
  all('Всё время');

  const StockChartPeriod(this.label);
  final String label;
}

/// Котировка акции (учебный проект: цены в RUB за 1 акцию).
class StockQuote {
  final String ticker;
  final String name;
  final double priceRub;

  const StockQuote({
    required this.ticker,
    required this.name,
    required this.priceRub,
  });
}

/// Список акций с демо-ценами в рублях (для практик тестировщиков).
/// В реальном приложении здесь был бы запрос к API (Finnhub, Alpha Vantage и т.д.).
/// Вызовы асинхронны (Future), не блокируют UI; при переходе на реальный API сохранять async/await и таймауты.
class StocksApi {
  static const _timeout = Duration(seconds: 10);

  static const _mockStocks = [
    StockQuote(ticker: 'AAPL', name: 'Apple Inc.', priceRub: 18500),
    StockQuote(ticker: 'GOOGL', name: 'Alphabet (Google)', priceRub: 16500),
    StockQuote(ticker: 'MSFT', name: 'Microsoft', priceRub: 42000),
    StockQuote(ticker: 'AMZN', name: 'Amazon', priceRub: 19500),
    StockQuote(ticker: 'TSLA', name: 'Tesla', priceRub: 25000),
    StockQuote(ticker: 'META', name: 'Meta Platforms', priceRub: 5200),
    StockQuote(ticker: 'NVDA', name: 'NVIDIA', priceRub: 38000),
    StockQuote(ticker: 'SBER', name: 'Сбербанк', priceRub: 280),
    StockQuote(ticker: 'GAZP', name: 'Газпром', priceRub: 135),
  ];

  /// Возвращает список акций с демо-ценами в рублях (имитация задержки сети).
  static Future<List<StockQuote>> fetch() async {
    return _fetchImpl().timeout(_timeout);
  }

  static Future<List<StockQuote>> _fetchImpl() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockStocks);
  }

  /// Демо-история OHLC для свечного графика (псевдо-случайные свечи от текущей цены в прошлое).
  static Future<List<CandlePoint>> fetchHistory(StockQuote stock, StockChartPeriod period) async {
    return _fetchHistoryImpl(stock, period).timeout(_timeout);
  }

  static Future<List<CandlePoint>> _fetchHistoryImpl(StockQuote stock, StockChartPeriod period) async {
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
        step = const Duration(hours: 43, minutes: 48); // ~1.825 дня
        break;
      case StockChartPeriod.all:
        count = 300;
        step = const Duration(days: 30);
        break;
    }
    final seed = stock.ticker.hashCode + period.index;
    final points = <CandlePoint>[];
    double close = stock.priceRub;
    var t = now;
    for (var i = 0; i < count; i++) {
      final open = close;
      final variation = 0.015 * ((seed + i * 7) % 100) / 100 - 0.0075;
      close = open * (1 + variation);
      final low = open < close ? open : close;
      final high = open > close ? open : close;
      final range = (high - low).clamp(0.001, double.infinity);
      final low2 = low - range * 0.2 * ((seed + i * 11) % 50) / 50;
      final high2 = high + range * 0.2 * ((seed + i * 13) % 50) / 50;
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
