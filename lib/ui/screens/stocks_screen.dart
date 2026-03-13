// Экран «Акции и крипто»: вкладки Акции | Крипто, свечные графики OHLC, покупка в портфель.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/expense.dart';
import '../../domain/models/portfolio_holding.dart';
import '../../domain/models/portfolio_transaction.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../../services/crypto_api.dart';
import '../../services/stocks_api.dart';
import '../../state/app_scope.dart';
import '../widgets/candlestick_chart.dart';
import '../widgets/theme_action.dart';
import '../widgets/settings_action.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> with SingleTickerProviderStateMixin {
  List<StockQuote> _stocks = [];
  List<CryptoQuote> _crypto = [];
  Exception? _error;
  final PortfolioRepository _repo = PortfolioRepository();
  StockChartPeriod _period = StockChartPeriod.day;
  Map<String, List<CandlePoint>> _stockHistory = {};
  Map<String, List<CandlePoint>> _cryptoHistory = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStocks();
    _loadCrypto();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStocks() async {
    setState(() => _error = null);
    try {
      final list = await StocksApi.fetch();
      if (mounted) {
        setState(() => _stocks = list);
        _loadStockHistory();
      }
    } catch (e) {
      if (mounted) setState(() => _error = e is Exception ? e : Exception(e.toString()));
    }
  }

  Future<void> _loadStockHistory() async {
    final next = <String, List<CandlePoint>>{};
    for (final s in _stocks) {
      next[s.ticker] = await StocksApi.fetchHistory(s, _period);
    }
    if (mounted) setState(() => _stockHistory = next);
  }

  Future<void> _loadCrypto() async {
    try {
      final list = await CryptoApi.fetch();
      if (mounted) {
        setState(() => _crypto = list);
        _loadCryptoHistory();
      }
    } catch (e) {
      if (mounted) setState(() => _error = e is Exception ? e : Exception(e.toString()));
    }
  }

  Future<void> _loadCryptoHistory() async {
    final next = <String, List<CandlePoint>>{};
    for (final c in _crypto) {
      next[c.symbol] = await CryptoApi.fetchHistory(c, _period);
    }
    if (mounted) setState(() => _cryptoHistory = next);
  }

  void _setPeriod(StockChartPeriod p) {
    if (p == _period) return;
    setState(() => _period = p);
    _loadStockHistory();
    _loadCryptoHistory();
  }

  Future<void> _buyStock(StockQuote stock, double shares) async {
    if (shares <= 0) return;
    final costRub = stock.priceRub * shares;
    final balance = await _repo.getBalance();
    if (costRub > balance) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Недостаточно средств на балансе портфеля')),
        );
      }
      return;
    }
    final existingRows = await _repo.getHoldings();
    final list = existingRows.where((h) => h.currency == stock.ticker).toList();
    final existing = list.isEmpty ? null : list.first;
    double newAmount;
    double newAvgRate;
    if (existing != null) {
      newAmount = existing.amount + shares;
      newAvgRate = (existing.avgRate * existing.amount + stock.priceRub * shares) / newAmount;
    } else {
      newAmount = shares;
      newAvgRate = stock.priceRub;
    }
    await _repo.setBalance(balance - costRub);
    await _repo.saveOrUpdateHolding(PortfolioHolding(
      id: existing?.id ?? 0,
      currency: stock.ticker,
      amount: newAmount,
      avgRate: newAvgRate,
      updatedAt: DateTime.now(),
    ));
    await _repo.addTransaction(PortfolioTransaction(
      id: 0,
      createdAt: DateTime.now(),
      type: 'buy',
      currency: stock.ticker,
      amount: shares,
      rate: stock.priceRub,
      totalBase: costRub,
    ));
    if (mounted) {
      final state = AppScope.of(context);
      await state.add(Expense(
        id: 'stock_buy_${DateTime.now().microsecondsSinceEpoch}',
        title: 'Покупка ${stock.ticker}',
        amount: costRub,
        category: 'Портфель',
        date: DateTime.now(),
        isIncome: false,
      ));
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Куплено ${NumberFormat('##0.##', 'ru_RU').format(shares)} ${stock.ticker}')),
      );
    }
  }

  Future<void> _buyCrypto(CryptoQuote crypto, double amount) async {
    if (amount <= 0) return;
    final costRub = crypto.priceRub * amount;
    final balance = await _repo.getBalance();
    if (costRub > balance) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Недостаточно средств на балансе портфеля')),
        );
      }
      return;
    }
    final existingRows = await _repo.getHoldings();
    final list = existingRows.where((h) => h.currency == crypto.symbol).toList();
    final existing = list.isEmpty ? null : list.first;
    double newAmount;
    double newAvgRate;
    if (existing != null) {
      newAmount = existing.amount + amount;
      newAvgRate = (existing.avgRate * existing.amount + crypto.priceRub * amount) / newAmount;
    } else {
      newAmount = amount;
      newAvgRate = crypto.priceRub;
    }
    await _repo.setBalance(balance - costRub);
    await _repo.saveOrUpdateHolding(PortfolioHolding(
      id: existing?.id ?? 0,
      currency: crypto.symbol,
      amount: newAmount,
      avgRate: newAvgRate,
      updatedAt: DateTime.now(),
    ));
    await _repo.addTransaction(PortfolioTransaction(
      id: 0,
      createdAt: DateTime.now(),
      type: 'buy',
      currency: crypto.symbol,
      amount: amount,
      rate: crypto.priceRub,
      totalBase: costRub,
    ));
    if (mounted) {
      final state = AppScope.of(context);
      await state.add(Expense(
        id: 'crypto_buy_${DateTime.now().microsecondsSinceEpoch}',
        title: 'Покупка ${crypto.symbol}',
        amount: costRub,
        category: 'Портфель',
        date: DateTime.now(),
        isIncome: false,
      ));
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Куплено ${NumberFormat('##0.####', 'ru_RU').format(amount)} ${crypto.symbol}')),
      );
    }
  }

  void _showBuyStockDialog(StockQuote stock) {
    final c = TextEditingController(text: '1');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Купить ${stock.ticker}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stock.name, style: Theme.of(ctx).textTheme.bodySmall),
            Text('Цена: ${NumberFormat('#,###', 'ru_RU').format(stock.priceRub)} ₽ за акцию'),
            const SizedBox(height: 12),
            TextField(
              controller: c,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Количество акций',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final n = double.tryParse(c.text.trim().replaceFirst(',', '.'));
              Navigator.pop(ctx);
              if (n != null && n > 0) _buyStock(stock, n);
            },
            child: const Text('Купить'),
          ),
        ],
      ),
    );
  }

  void _showBuyCryptoDialog(CryptoQuote crypto) {
    final c = TextEditingController(text: '0.001');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Купить ${crypto.symbol}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(crypto.name, style: Theme.of(ctx).textTheme.bodySmall),
            Text('Цена: ${NumberFormat('#,###', 'ru_RU').format(crypto.priceRub)} ₽ за 1 ${crypto.symbol}'),
            const SizedBox(height: 12),
            TextField(
              controller: c,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Количество',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final n = double.tryParse(c.text.trim().replaceFirst(',', '.'));
              Navigator.pop(ctx);
              if (n != null && n > 0) _buyCrypto(crypto, n);
            },
            child: const Text('Купить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'ru_RU');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Акции и крипто'),
        actions: const [ThemeAction(), SettingsAction()],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Акции'),
            Tab(text: 'Крипто'),
          ],
        ),
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ошибка', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      _loadStocks();
                      _loadCrypto();
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _stocks.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadStocks,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _periodChips(),
                            ..._stocks.map((s) => _buildStockCard(context, s, fmt)),
                          ],
                        ),
                      ),
                _crypto.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadCrypto,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _periodChips(),
                            ..._crypto.map((c) => _buildCryptoCard(context, c, fmt)),
                          ],
                        ),
                      ),
              ],
            ),
    );
  }

  Widget _periodChips() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: StockChartPeriod.values.map((p) {
            final selected = p == _period;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(p.label),
                selected: selected,
                onSelected: (_) => _setPeriod(p),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStockCard(BuildContext context, StockQuote s, NumberFormat fmt) {
    final points = _stockHistory[s.ticker];
    final hasChart = points != null && points.length >= 2;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${s.ticker} — ${s.name}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${fmt.format(s.priceRub)} ₽ за акцию',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => _showBuyStockDialog(s),
                  child: const Text('Купить'),
                ),
              ],
            ),
            if (hasChart) ...[
              const SizedBox(height: 12),
              const Text('Свечной график OHLC', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
              const SizedBox(height: 4),
              SizedBox(
                height: 180,
                child: CandlestickChart(points: points, currentPrice: s.priceRub),
              ),
            ] else if (points == null) ...[
              const SizedBox(height: 12),
              const SizedBox(
                height: 80,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCryptoCard(BuildContext context, CryptoQuote c, NumberFormat fmt) {
    final points = _cryptoHistory[c.symbol];
    final hasChart = points != null && points.length >= 2;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${c.symbol} — ${c.name}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${fmt.format(c.priceRub)} ₽ за 1 ${c.symbol}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => _showBuyCryptoDialog(c),
                  child: const Text('Купить'),
                ),
              ],
            ),
            if (hasChart) ...[
              const SizedBox(height: 12),
              const Text('Свечной график OHLC', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
              const SizedBox(height: 4),
              SizedBox(
                height: 180,
                child: CandlestickChart(points: points, currentPrice: c.priceRub),
              ),
            ] else if (points == null) ...[
              const SizedBox(height: 12),
              const SizedBox(
                height: 80,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
