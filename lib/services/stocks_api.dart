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

  static Future<List<StockQuote>> fetch() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockStocks);
  }
}
