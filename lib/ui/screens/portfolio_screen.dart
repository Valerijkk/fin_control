// Экран «Портфель»: баланс, активы (валюты и акции), купить/продать, учёт в расходах/доходах.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/portfolio_holding.dart';
import '../../domain/models/portfolio_transaction.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../../services/rates_api.dart';
import '../../state/app_scope.dart';
import '../widgets/app_bar_title.dart';
import '../widgets/section_title.dart';
import '../widgets/theme_action.dart';
import '../widgets/settings_action.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import '../../config/telemetry.dart';

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
    if (!mounted) return;
    setState(() {
      _balance = balance;
      _baseCurrency = base;
      _holdings = holdings;
      _transactions = transactions;
    });
    debugPrint('[FinControl] PortfolioScreen: загружено — баланс ${balance.toStringAsFixed(2)} $_baseCurrency, ${holdings.length} позиций, ${transactions.length} сделок');
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
    return r != null ? 1 / r : null;
  }

  /// Стоимость amount валюты в базовой.
  double? _costInBase(double amount, String currency) {
    final rate = _rateToBase(currency);
    return rate == null ? null : amount * rate;
  }

  /// Общая стоимость портфеля (баланс + текущая стоимость активов).
  double _totalEquity() {
    double sum = _balance;
    for (final h in _holdings) {
      final worth = _costInBase(h.amount, h.currency);
      if (worth != null) {
        sum += worth;
      } else {
        sum += h.amount * h.avgRate;
      }
    }
    return sum;
  }

  /// Средняя цена входа (cost basis) по всем активам.
  double _costBasis() {
    return _holdings.fold(0.0, (s, h) => s + h.amount * h.avgRate);
  }

  /// Нереализованный PnL: текущая стоимость активов минус cost basis.
  double _unrealizedPnl() {
    double marketValue = 0;
    double cost = 0;
    for (final h in _holdings) {
      final worth = _costInBase(h.amount, h.currency);
      marketValue += worth ?? (h.amount * h.avgRate);
      cost += h.amount * h.avgRate;
    }
    return marketValue - cost;
  }

  /// Реализованный PnL: всего выведено от продаж минус всего вложено в покупки.
  double _realizedPnl() {
    double bought = 0, sold = 0;
    for (final t in _transactions) {
      if (t.type == 'buy') {
        bought += t.totalBase;
      } else {
        sold += t.totalBase;
      }
    }
    return sold - bought;
  }

  /// ROI % от начального баланса (100_000 по умолчанию).
  double _roiPercent() {
    const initial = 100000.0;
    final equity = _totalEquity();
    if (initial <= 0) return 0;
    return (equity - initial) / initial * 100;
  }

  /// Доли активов в % от общей стоимости (для аллокации).
  List<({String currency, double percent, double value})> _allocation() {
    final total = _totalEquity();
    if (total <= 0) return [];
    final list = <({String currency, double percent, double value})>[];
    for (final h in _holdings) {
      final value = _costInBase(h.amount, h.currency) ?? (h.amount * h.avgRate);
      list.add((currency: h.currency, percent: value / total * 100, value: value));
    }
    final balanceShare = _balance / total * 100;
    if (balanceShare > 0.5) {
      list.insert(0, (currency: _baseCurrency, percent: balanceShare, value: _balance));
    }
    return list;
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
      if (sentryDsn.isNotEmpty) {
        Sentry.addBreadcrumb(Breadcrumb(
          message: 'Покупка: $amount $currency',
          category: 'portfolio',
          level: SentryLevel.info,
        ));
      }
      if (mounted) _showSnack('Куплено $amount $currency');
      if (appMetricaApiKey.isNotEmpty) {
        AppMetrica.reportEventWithMap('portfolio_buy', {
          'currency': currency,
          'amount': amount.toString(),
        });
      }
      debugPrint('[FinControl] PortfolioScreen: покупка $amount $currency по ${rate.toStringAsFixed(2)} ₽, итого ${costInBase.toStringAsFixed(2)} ₽');
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
      if (sentryDsn.isNotEmpty) {
        Sentry.addBreadcrumb(Breadcrumb(
          message: 'Продажа: $amount ${holding.currency}',
          category: 'portfolio',
          level: SentryLevel.info,
        ));
      }
      if (mounted) _showSnack('Продано $amount ${holding.currency}');
      if (appMetricaApiKey.isNotEmpty) {
        AppMetrica.reportEventWithMap('portfolio_sell', {
          'currency': holding.currency,
          'amount': amount.toString(),
        });
      }
      debugPrint('[FinControl] PortfolioScreen: продажа $amount ${holding.currency} по ${rate.toStringAsFixed(2)} ₽, итого ${creditInBase.toStringAsFixed(2)} ₽');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _pnlRow(BuildContext context, String label, double value, bool? positive, {String suffix = ''}) {
    final fmt = NumberFormat('##0.00', 'ru_RU');
    final isPositive = positive == true;
    final isNegative = positive == false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            '${fmt.format(value)}$suffix',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isPositive ? Colors.green.shade700 : (isNegative ? Colors.red.shade700 : null),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
              padding: const EdgeInsets.all(AppTheme.screenPadding),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.cardContentPadding),
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
                if (_rates != null && (_holdings.isNotEmpty || _transactions.isNotEmpty)) ...[
                  const SizedBox(height: AppTheme.sectionSpacing),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.cardContentPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Доходность (PnL)', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          _pnlRow(context, 'Общая стоимость', _totalEquity(), null),
                          _pnlRow(context, 'Cost basis (вложения)', _costBasis(), null),
                          _pnlRow(context, 'Нереализ. PnL', _unrealizedPnl(), _unrealizedPnl() >= 0),
                          _pnlRow(context, 'Реализ. PnL', _realizedPnl(), _realizedPnl() >= 0),
                          _pnlRow(context, 'ROI', _roiPercent(), _roiPercent() >= 0, suffix: '%'),
                        ],
                      ),
                    ),
                  ),
                ],
                if (_rates != null && _holdings.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.sectionSpacing),
                  SectionTitle(title: 'Аллокация активов'),
                  const SizedBox(height: AppTheme.sectionSpacing),
                  ..._allocation().map((a) {
                    final color = a.currency == _baseCurrency
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.secondaryContainer;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(a.currency, style: Theme.of(context).textTheme.labelMedium),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (a.percent / 100).clamp(0.0, 1.0),
                                minHeight: 20,
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${fmt.format(a.percent)}%', style: Theme.of(context).textTheme.labelMedium),
                        ],
                      ),
                    );
                  }),
                ],
                const SizedBox(height: AppTheme.sectionSpacingLarge),
                SectionTitle(title: 'Активы'),
                const SizedBox(height: AppTheme.sectionSpacing),
                if (_holdings.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.cardContentPadding),
                      child: const Center(child: Text('Нет позиций. Купите валюту по текущему курсу.')),
                    ),
                  )
                else
                  ..._holdings.map((h) {
                    final worth = _costInBase(h.amount, h.currency);
                    final displayWorth = worth ?? (h.amount * h.avgRate);
                    final isStock = _rates == null || !_rates!.rates.containsKey(h.currency);
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppTheme.sectionSpacing),
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
                const SizedBox(height: AppTheme.sectionSpacingLarge),
                if (_rates != null) ...[
                  SectionTitle(title: 'Купить валюту'),
                  const SizedBox(height: AppTheme.sectionSpacing),
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
                const SizedBox(height: AppTheme.sectionSpacingLarge),
                SectionTitle(title: 'История сделок'),
                const SizedBox(height: AppTheme.sectionSpacing),
                if (_transactions.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.cardContentPadding),
                      child: const Text('Пока нет сделок'),
                    ),
                  )
                else
                  ..._transactions.take(15).map((t) {
                    final d = DateFormat('dd.MM HH:mm').format(t.createdAt);
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppTheme.sectionSpacing),
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
              decoration: InputDecoration(labelText: 'Сумма в $currency'),
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
              decoration: const InputDecoration(labelText: 'Сумма к продаже'),
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
