import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/expense.dart';
import '../../domain/models/portfolio_holding.dart';
import '../../domain/models/portfolio_transaction.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../../services/stocks_api.dart';
import '../../state/app_scope.dart';
import '../widgets/app_bar_title.dart';
import '../widgets/theme_action.dart';
import '../widgets/settings_action.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  List<StockQuote> _stocks = [];
  Exception? _error;
  final PortfolioRepository _repo = PortfolioRepository();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final list = await StocksApi.fetch();
      if (mounted) setState(() => _stocks = list);
    } catch (e) {
      if (mounted) setState(() => _error = e is Exception ? e : Exception(e.toString()));
    }
  }

  Future<void> _buy(StockQuote stock, double shares) async {
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

  void _showBuyDialog(StockQuote stock) {
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
              if (n != null && n > 0) _buy(stock, n);
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
      appBar: const AppBarTitle(
        title: 'Акции',
        actions: [ThemeAction(), SettingsAction()],
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ошибка', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _load, child: const Text('Повторить')),
                ],
              ),
            )
          : _stocks.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _stocks.length,
                    itemBuilder: (context, i) {
                      final s = _stocks[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text('${s.ticker} — ${s.name}'),
                          subtitle: Text('${fmt.format(s.priceRub)} ₽ за акцию'),
                          trailing: FilledButton(
                            onPressed: () => _showBuyDialog(s),
                            child: const Text('Купить'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
