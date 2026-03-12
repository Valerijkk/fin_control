import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/expense.dart';
import '../../domain/models/portfolio_holding.dart';
import '../../domain/models/portfolio_transaction.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../../services/rates_api.dart';
import '../../state/app_scope.dart';
import '../widgets/app_bar_title.dart';
import '../widgets/theme_action.dart';
import '../widgets/settings_action.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final PortfolioRepository _repo = PortfolioRepository();
  double _balance = 0;
  String _baseCurrency = 'RUB';
  List<PortfolioHolding> _holdings = [];
  List<PortfolioTransaction> _transactions = [];
  Rates? _rates;
  Exception? _ratesError;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final balance = await _repo.getBalance();
    final base = await _repo.getBaseCurrency();
    final holdings = await _repo.getHoldings();
    final transactions = await _repo.getTransactions();
    setState(() {
      _balance = balance;
      _baseCurrency = base;
      _holdings = holdings;
      _transactions = transactions;
    });
    _loadRates();
  }

  Future<void> _loadRates() async {
    try {
      final r = await RatesApi.fetch();
      if (mounted) setState(() => _rates = r);
    } catch (e) {
      if (mounted) setState(() => _ratesError = e is Exception ? e : Exception(e.toString()));
    }
  }

  /// Стоимость 1 единицы валюты в базовой (RUB).
  double? _rateToBase(String currency) {
    if (_rates == null) return null;
    if (currency == 'RUB') return 1.0;
    final r = _rates!.rates[currency];
    return r != null && r > 0 ? 1 / r : null;
  }

  /// Стоимость amount валюты в базовой.
  double? _costInBase(double amount, String currency) {
    final rate = _rateToBase(currency);
    return rate == null ? null : amount * rate;
  }

  Future<void> _buy(String currency, double amount) async {
    final rate = _rateToBase(currency);
    if (rate == null || _rates == null) {
      _showSnack('Не удалось получить курс');
      return;
    }
    final costInBase = amount * rate;
    if (costInBase > _balance) {
      _showSnack('Недостаточно средств');
      return;
    }
    setState(() => _loading = true);
    try {
      await _repo.setBalance(_balance - costInBase);
      final list = _holdings.where((h) => h.currency == currency).toList();
      final existing = list.isEmpty ? null : list.first;
      double newAmount;
      double newAvgRate;
      if (existing != null) {
        newAmount = existing.amount + amount;
        newAvgRate = (existing.avgRate * existing.amount + rate * amount) / newAmount;
      } else {
        newAmount = amount;
        newAvgRate = rate;
      }
      final holding = PortfolioHolding(
        id: existing?.id ?? 0,
        currency: currency,
        amount: newAmount,
        avgRate: newAvgRate,
        updatedAt: DateTime.now(),
      );
      await _repo.saveOrUpdateHolding(holding);
      await _repo.addTransaction(PortfolioTransaction(
        id: 0,
        createdAt: DateTime.now(),
        type: 'buy',
        currency: currency,
        amount: amount,
        rate: rate,
        totalBase: costInBase,
      ));
      if (mounted) {
        final state = AppScope.of(context);
        await state.add(Expense(
          id: 'portfolio_buy_${DateTime.now().microsecondsSinceEpoch}',
          title: 'Покупка $currency',
          amount: costInBase,
          category: 'Портфель',
          date: DateTime.now(),
          isIncome: false,
        ));
      }
      await _load();
      if (mounted) _showSnack('Куплено $amount $currency');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sell(PortfolioHolding holding, double amount) async {
    if (amount <= 0 || amount > holding.amount) {
      _showSnack('Некорректная сумма продажи');
      return;
    }
    double rate = _rateToBase(holding.currency) ?? 0;
    if (rate <= 0) rate = holding.avgRate;
    final creditInBase = amount * rate;
    setState(() => _loading = true);
    try {
      await _repo.setBalance(_balance + creditInBase);
      final newAmount = holding.amount - amount;
      if (newAmount <= 0) {
        await _repo.deleteHolding(holding.currency);
      } else {
        await _repo.saveOrUpdateHolding(PortfolioHolding(
          id: holding.id,
          currency: holding.currency,
          amount: newAmount,
          avgRate: holding.avgRate,
          updatedAt: DateTime.now(),
        ));
      }
      await _repo.addTransaction(PortfolioTransaction(
        id: 0,
        createdAt: DateTime.now(),
        type: 'sell',
        currency: holding.currency,
        amount: amount,
        rate: rate,
        totalBase: creditInBase,
      ));
      if (mounted) {
        final state = AppScope.of(context);
        await state.add(Expense(
          id: 'portfolio_sell_${DateTime.now().microsecondsSinceEpoch}',
          title: 'Продажа ${holding.currency}',
          amount: creditInBase,
          category: 'Портфель',
          date: DateTime.now(),
          isIncome: true,
        ));
      }
      await _load();
      if (mounted) _showSnack('Продано $amount ${holding.currency}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('##0.00', 'ru_RU');

    return Scaffold(
      appBar: const AppBarTitle(
        title: 'Портфель',
        actions: [ThemeAction(), SettingsAction()],
      ),
      body: _ratesError != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ошибка загрузки курсов', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _loadRates, child: const Text('Повторить')),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Баланс ($_baseCurrency)', style: Theme.of(context).textTheme.titleSmall),
                        Text(
                          fmt.format(_balance),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        if (_rates != null)
                          TextButton.icon(
                            onPressed: _loading ? null : _loadRates,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Обновить курсы'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Активы'),
                const SizedBox(height: 10),
                if (_holdings.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('Нет позиций. Купите валюту по текущему курсу.')),
                    ),
                  )
                else
                  ..._holdings.map((h) {
                    final worth = _costInBase(h.amount, h.currency);
                    final displayWorth = worth ?? (h.amount * h.avgRate);
                    final isStock = _rates == null || !_rates!.rates.containsKey(h.currency);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('${h.currency}: ${fmt.format(h.amount)}${isStock ? ' (акции)' : ''}'),
                        subtitle: Text(
                          '≈ ${fmt.format(displayWorth)} $_baseCurrency • ${isStock ? 'средняя цена ' : ''}${fmt.format(h.avgRate)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FilledButton.tonal(
                              onPressed: _loading ? null : () => _showSellDialog(h),
                              child: const Text('Продать'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 16),
                if (_rates != null) ...[
                  _SectionTitle(title: 'Купить валюту'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _rates!.rates.keys.where((c) => c != _baseCurrency).map((c) {
                      final rate = _rateToBase(c);
                      if (rate == null) return const SizedBox.shrink();
                      return FilledButton(
                        onPressed: _loading ? null : () => _showBuyDialog(c, rate),
                        child: Text('Купить $c (1 $c = ${fmt.format(rate)} $_baseCurrency)'),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 28),
                _SectionTitle(title: 'История сделок'),
                const SizedBox(height: 10),
                if (_transactions.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Пока нет сделок'),
                    ),
                  )
                else
                  ..._transactions.take(15).map((t) {
                    final d = DateFormat('dd.MM HH:mm').format(t.createdAt);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('${t.type == 'buy' ? 'Покупка' : 'Продажа'} ${t.currency}: ${fmt.format(t.amount)}'),
                        subtitle: Text('$d • ${fmt.format(t.totalBase)} $_baseCurrency'),
                      ),
                    );
                  }),
              ],
            ),
    );
  }

  void _showBuyDialog(String currency, double ratePerUnit) {
    final c = TextEditingController(text: '100');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Купить $currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Курс: 1 $currency = ${NumberFormat('##0.00', 'ru_RU').format(ratePerUnit)} $_baseCurrency'),
            const SizedBox(height: 8),
            TextField(
              controller: c,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Сумма в $currency', border: const OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(c.text.trim().replaceFirst(',', '.'));
              Navigator.pop(ctx);
              if (amount != null && amount > 0) _buy(currency, amount);
            },
            child: const Text('Купить'),
          ),
        ],
      ),
    );
  }

  void _showSellDialog(PortfolioHolding holding) {
    final fmt = NumberFormat('##0.00', 'ru_RU');
    final c = TextEditingController(text: fmt.format(holding.amount));
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Продать ${holding.currency}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Доступно: ${fmt.format(holding.amount)} ${holding.currency}'),
            const SizedBox(height: 8),
            TextField(
              controller: c,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Сумма к продаже', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(c.text.trim().replaceFirst(',', '.'));
              Navigator.pop(ctx);
              if (amount != null && amount > 0) _sell(holding, amount);
            },
            child: const Text('Продать'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
