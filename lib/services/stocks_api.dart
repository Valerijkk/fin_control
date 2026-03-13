/// Точка истории цены для графика.
class StockPricePoint {
  final DateTime time;
  final double priceRub;

  const StockPricePoint({required this.time, required this.priceRub});
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
class StocksApi {
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
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockStocks);
  }

  /// Демо-история цен для графика (псевдо-случайная траектория от текущей цены в прошлое).
  static Future<List<StockPricePoint>> fetchHistory(StockQuote stock, StockChartPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final now = DateTime.now();
    final int count;
    final Duration step;
    switch (period) {
      case StockChartPeriod.hour:
        count = 24;
        step = const Duration(minutes: 2, seconds: 30);
        break;
      case StockChartPeriod.day:
        count = 24;
        step = const Duration(hours: 1);
        break;
      case StockChartPeriod.week:
        count = 7;
        step = const Duration(days: 1);
        break;
      case StockChartPeriod.month:
        count = 30;
        step = const Duration(days: 1);
        break;
      case StockChartPeriod.year:
        count = 12;
        step = const Duration(days: 30);
        break;
      case StockChartPeriod.all:
        count = 24;
        step = const Duration(days: 30);
        break;
    }
    final seed = stock.ticker.hashCode + period.index;
    final points = <StockPricePoint>[];
    double p = stock.priceRub;
    var t = now;
    for (var i = 0; i < count; i++) {
      points.insert(0, StockPricePoint(time: t, priceRub: p));
      t = t.subtract(step);
      final variation = 0.02 * ((seed + i * 7) % 100) / 100 - 0.01;
      p = p * (1 + variation);
    }
    points.insert(0, StockPricePoint(time: t, priceRub: p));
    return points;
  }
}
