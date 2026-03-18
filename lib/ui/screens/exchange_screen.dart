// Экран «Обменник»: выбор валют, конвертация, оповещения по курсу, отложенные обмены, история.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../domain/models/exchange_operation.dart';
import '../../domain/models/limit_order.dart';
import '../../domain/models/price_alert.dart';
import '../../domain/repositories/exchange_repository.dart';
import '../../domain/repositories/limit_orders_repository.dart';
import '../../domain/repositories/price_alerts_repository.dart';
import '../../services/rates_api.dart' show Rates, RatesApi, kCurrencyCodes;
import '../widgets/app_bar_title.dart';
import '../widgets/section_title.dart';
import '../widgets/theme_action.dart';
import '../widgets/settings_action.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import '../../config/telemetry.dart';

/// Список валют для выпадающих списков: RUB + все коды из API.
final _currencies = ['RUB', ...kCurrencyCodes];

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final ExchangeRepository _repo = ExchangeRepository();
  final PriceAlertsRepository _alertsRepo = PriceAlertsRepository();
  final LimitOrdersRepository _ordersRepo = LimitOrdersRepository();
  final _amountController = TextEditingController(text: '1000');
  String _currencyFrom = 'RUB';
  String _currencyTo = 'USD';
  Rates? _rates;
  Exception? _ratesError;
  List<ExchangeOperation> _history = [];
  List<PriceAlert> _alerts = [];
  List<LimitOrder> _limitOrders = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadRates();
    _loadHistory();
    _loadAlertsAndOrders();
  }

  Future<void> _loadAlertsAndOrders() async {
    final alerts = await _alertsRepo.getAll(onlyPending: false);
    final orders = await _ordersRepo.getAll();
    if (mounted) {
      setState(() {
        _alerts = alerts;
        _limitOrders = orders;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Загружает курсы с API (или из кэша). При ошибке пишет в [_ratesError].
  Future<void> _loadRates() async {
    setState(() {
      _rates = null;
      _ratesError = null;
    });
    try {
      final r = await RatesApi.fetch();
      if (mounted) {
        setState(() => _rates = r);
        if (sentryDsn.isNotEmpty) {
          Sentry.addBreadcrumb(Breadcrumb(
            message: 'Курсы загружены (${r.source})',
            category: 'api',
            level: SentryLevel.info,
            data: {'count': r.rates.length, 'source': r.source},
          ));
        }
        debugPrint('[FinControl] ExchangeScreen: курсы загружены (${r.source}), ${r.rates.length} валют');
        if (appMetricaApiKey.isNotEmpty) {
          AppMetrica.reportEvent('rates_loaded');
        }
        _checkAlertsAndLimitOrders(r);
      }
    } catch (e) {
      debugPrint('[FinControl] ExchangeScreen: ошибка загрузки курсов — $e');
      if (mounted) setState(() => _ratesError = e is Exception ? e : Exception(e.toString()));
    }
  }

  /// Текущий курс from -> to (сколько to за 1 from).
  double? _getRate(Rates r, String from, String to) {
    if (from == to) return 1.0;
    final rates = r.rates;
    if (from == 'RUB') return rates[to];
    if (to == 'RUB') {
      final x = rates[from];
      return x != null && x > 0 ? 1 / x : null;
    }
    final fromRate = rates[from];
    final toRate = rates[to];
    if (fromRate == null || toRate == null || fromRate <= 0) return null;
    return toRate / fromRate;
  }

  /// Проверяет срабатывание оповещений и отложенных обменов по текущим курсам [r].
  /// Оповещение: срабатывает при rate >= targetRate (isAbove) или rate <= targetRate (!isAbove).
  /// Limit order: при том же условии — создаётся операция обмена, статус ордера переводится в done.
  /// После изменений обновляет списки _alerts/_limitOrders и историю обменов.
  Future<void> _checkAlertsAndLimitOrders(Rates r) async {
    final fmt = NumberFormat('##0.00', 'ru_RU');
    for (final alert in _alerts.where((a) => !a.notified)) {
      final rate = _getRate(r, alert.currencyFrom, alert.currencyTo);
      if (rate == null) continue;
      final triggered = alert.isAbove ? rate >= alert.targetRate : rate <= alert.targetRate;
      if (triggered && mounted) {
        await _alertsRepo.markNotified(alert.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Оповещение: ${alert.currencyFrom}/${alert.currencyTo} ${alert.isAbove ? "≥" : "≤"} ${fmt.format(alert.targetRate)} (сейчас ${fmt.format(rate)})',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
    final pending = await _ordersRepo.getPending();
    for (final order in pending) {
      final rate = _getRate(r, order.currencyFrom, order.currencyTo);
      if (rate == null) continue;
      final triggered = order.isAbove ? rate >= order.targetRate : rate <= order.targetRate;
      if (triggered && mounted) {
        final amountTo = order.amountFrom * order.targetRate;
        await _repo.add(ExchangeOperation(
          id: 0,
          createdAt: DateTime.now(),
          amountFrom: order.amountFrom,
          currencyFrom: order.currencyFrom,
          amountTo: amountTo,
          currencyTo: order.currencyTo,
          rateUsed: order.targetRate,
        ));
        await _ordersRepo.setStatus(order.id, 'done');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Отложенный обмен исполнен: ${fmt.format(order.amountFrom)} ${order.currencyFrom} → ${fmt.format(amountTo)} ${order.currencyTo}',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
    await _loadAlertsAndOrders();
    if (mounted) _loadHistory();
  }

  /// Подгружает историю операций обмена из [ExchangeRepository].
  Future<void> _loadHistory() async {
    final list = await _repo.getAll();
    if (mounted) setState(() => _history = list);
  }

  /// Конвертация: курсы от RUB (1 RUB = rates[X] в валюте X).
  double? _convert(double amount, String from, String to) {
    if (_rates == null) return null;
    final r = _rates!.rates;
    if (from == to) return amount;
    if (from == 'RUB') {
      final rate = r[to];
      return rate != null ? amount * rate : null;
    }
    if (to == 'RUB') {
      final rate = r[from];
      return rate != null && rate > 0 ? amount / rate : null;
    }
    final fromRate = r[from];
    final toRate = r[to];
    if (fromRate == null || toRate == null || fromRate <= 0) return null;
    return amount / fromRate * toRate;
  }

  double? _rateUsed(String from, String to) {
    if (_rates == null) return null;
    if (from == to) return 1.0;
    final r = _rates!.rates;
    if (from == 'RUB') return r[to];
    if (to == 'RUB') {
      final x = r[from];
      return x != null && x > 0 ? 1 / x : null;
    }
    final fromRate = r[from];
    final toRate = r[to];
    if (fromRate == null || toRate == null || fromRate <= 0) return null;
    return toRate / fromRate;
  }

  Future<void> _performExchange() async {
    final amountStr = _amountController.text.trim();
    final amount = double.tryParse(amountStr.replaceFirst(',', '.'));
    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректную сумму')),
      );
      return;
    }
    final toAmount = _convert(amount, _currencyFrom, _currencyTo);
    final rate = _rateUsed(_currencyFrom, _currencyTo);
    if (toAmount == null || rate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Невозможно выполнить обмен для выбранной пары')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final op = ExchangeOperation(
        id: 0,
        createdAt: DateTime.now(),
        amountFrom: amount,
        currencyFrom: _currencyFrom,
        amountTo: toAmount,
        currencyTo: _currencyTo,
        rateUsed: rate,
      );
      await _repo.add(op);
      if (sentryDsn.isNotEmpty) {
        Sentry.addBreadcrumb(Breadcrumb(
          message: 'Обмен: $amount $_currencyFrom → ${toAmount.toStringAsFixed(2)} $_currencyTo',
          category: 'exchange',
          level: SentryLevel.info,
        ));
      }
      await _loadHistory();
      if (mounted) {
        final nf = NumberFormat('##0.00', 'ru_RU');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Обмен: ${nf.format(amount)} $_currencyFrom → ${nf.format(toAmount)} $_currencyTo')),
        );
        debugPrint('[FinControl] ExchangeScreen: обмен ${nf.format(amount)} $_currencyFrom → ${nf.format(toAmount)} $_currencyTo (курс ${nf.format(rate)})');
        if (appMetricaApiKey.isNotEmpty) {
          AppMetrica.reportEventWithMap('exchange_completed', {
            'currency_from': _currencyFrom,
            'currency_to': _currencyTo,
            'amount': amount.toString(),
          });
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('##0.00', 'ru_RU');
    final amount = double.tryParse(_amountController.text.trim().replaceFirst(',', '.')) ?? 0.0;
    final toAmount = _convert(amount, _currencyFrom, _currencyTo);

    return Scaffold(
      appBar: const AppBarTitle(
        title: 'Обменник',
        actions: [ThemeAction(), SettingsAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.screenPadding),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.cardContentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_ratesError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Ошибка загрузки курсов',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    )
                  else if (_rates == null)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ))
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Курсы (1 RUB): ${_rates!.rates.entries.take(5).map((e) => '${e.key} ${fmt.format(e.value)}').join(', ')}${_rates!.rates.length > 5 ? '…' : ''}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _loading ? null : _loadRates,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Обновить'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  const Text('Из валюты'),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    key: ValueKey('currency_from_$_currencyFrom'),
                    initialValue: _currencyFrom,
                    items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _currencyFrom = v ?? _currencyFrom),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Сумма'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  const Text('В валюту'),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    key: ValueKey('currency_to_$_currencyTo'),
                    initialValue: _currencyTo,
                    items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _currencyTo = v ?? _currencyTo),
                  ),
                  if (toAmount != null && amount > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Получите: ${fmt.format(toAmount)} $_currencyTo',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: (_rates != null && !_loading) ? _performExchange : null,
                    icon: _loading ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ) : const Icon(Icons.swap_horiz),
                    label: Text(_loading ? 'Обмен…' : 'Обменять'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.sectionSpacingLarge),
          SectionTitle(title: 'Оповещения по курсу'),
          const SizedBox(height: AppTheme.sectionSpacing),
          OutlinedButton.icon(
            onPressed: _rates == null ? null : () => _showAddAlertDialog(),
            icon: const Icon(Icons.add_alert, size: 20),
            label: const Text('Добавить оповещение'),
          ),
          if (_alerts.isNotEmpty) ...[
            const SizedBox(height: 8),
            ..._alerts.take(10).map((a) => Card(
              margin: const EdgeInsets.only(bottom: AppTheme.sectionSpacing),
              child: ListTile(
                title: Text(
                  '${a.currencyFrom}/${a.currencyTo} ${a.isAbove ? "≥" : "≤"} ${fmt.format(a.targetRate)}',
                ),
                subtitle: Text(a.notified ? 'Сработало' : 'Ожидание'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await _alertsRepo.delete(a.id);
                    if (mounted) _loadAlertsAndOrders();
                  },
                ),
              ),
            )),
          ],
          const SizedBox(height: AppTheme.sectionSpacingLarge),
          SectionTitle(title: 'Отложенные обмены (limit)'),
          const SizedBox(height: AppTheme.sectionSpacing),
          OutlinedButton.icon(
            onPressed: _rates == null ? null : () => _showAddLimitOrderDialog(),
            icon: const Icon(Icons.schedule, size: 20),
            label: const Text('Добавить отложенный обмен'),
          ),
          if (_limitOrders.isNotEmpty) ...[
            const SizedBox(height: 8),
            ..._limitOrders.take(10).map((o) => Card(
              margin: const EdgeInsets.only(bottom: AppTheme.sectionSpacing),
              child: ListTile(
                title: Text(
                  '${fmt.format(o.amountFrom)} ${o.currencyFrom} → ${o.currencyTo} при ${o.isAbove ? "≥" : "≤"} ${fmt.format(o.targetRate)}',
                ),
                subtitle: Text(o.status == 'pending' ? 'Ожидание' : o.status == 'done' ? 'Исполнен' : 'Отменён'),
                trailing: o.status == 'pending'
                    ? IconButton(
                        icon: const Icon(Icons.cancel_outlined),
                        onPressed: () async {
                          await _ordersRepo.setStatus(o.id, 'cancelled');
                          if (mounted) _loadAlertsAndOrders();
                        },
                      )
                    : null,
              ),
            )),
          ],
          const SizedBox(height: AppTheme.sectionSpacingLarge),
          SectionTitle(title: 'История обменов'),
          const SizedBox(height: AppTheme.sectionSpacing),
          if (_history.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.cardContentPadding),
                child: const Center(child: Text('Пока нет операций')),
              ),
            )
          else
            ..._history.take(20).map((op) {
              final d = DateFormat('dd.MM.yyyy HH:mm', 'ru_RU').format(op.createdAt);
              return Card(
                margin: const EdgeInsets.only(bottom: AppTheme.sectionSpacing),
                child: ListTile(
                  title: Text(
                    '${fmt.format(op.amountFrom)} ${op.currencyFrom} → ${fmt.format(op.amountTo)} ${op.currencyTo}',
                  ),
                  subtitle: Text('$d • курс ${fmt.format(op.rateUsed)}'),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showAddAlertDialog() {
    String from = _currencyFrom;
    String to = _currencyTo;
    final rateCtrl = TextEditingController();
    bool isAbove = true;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Оповещение по курсу'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: from,
                  decoration: const InputDecoration(labelText: 'Из валюты'),
                  items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDlg(() => from = v ?? from),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: to,
                  decoration: const InputDecoration(labelText: 'В валюту'),
                  items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDlg(() => to = v ?? to),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: rateCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Курс (1 из = X в)'),
                ),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Когда ≥')),
                    ButtonSegment(value: false, label: Text('Когда ≤')),
                  ],
                  selected: {isAbove},
                  onSelectionChanged: (s) => setDlg(() => isAbove = s.first),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            FilledButton(
              onPressed: () async {
                final rate = double.tryParse(rateCtrl.text.trim().replaceFirst(',', '.'));
                if (rate == null || rate <= 0) return;
                Navigator.pop(ctx);
                await _alertsRepo.add(PriceAlert(
                  id: 0,
                  currencyFrom: from,
                  currencyTo: to,
                  targetRate: rate,
                  isAbove: isAbove,
                  createdAt: DateTime.now(),
                ));
                _loadAlertsAndOrders();
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLimitOrderDialog() {
    String from = _currencyFrom;
    String to = _currencyTo;
    final amountCtrl = TextEditingController(text: '1000');
    final rateCtrl = TextEditingController();
    bool isAbove = true;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Отложенный обмен'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: from,
                  decoration: const InputDecoration(labelText: 'Из валюты'),
                  items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDlg(() => from = v ?? from),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Сумма'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: to,
                  decoration: const InputDecoration(labelText: 'В валюту'),
                  items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDlg(() => to = v ?? to),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: rateCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Исполнить при курсе (1 из = X в)'),
                ),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Когда ≥')),
                    ButtonSegment(value: false, label: Text('Когда ≤')),
                  ],
                  selected: {isAbove},
                  onSelectionChanged: (s) => setDlg(() => isAbove = s.first),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            FilledButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text.trim().replaceFirst(',', '.'));
                final rate = double.tryParse(rateCtrl.text.trim().replaceFirst(',', '.'));
                if (amount == null || amount <= 0 || rate == null || rate <= 0) return;
                Navigator.pop(ctx);
                await _ordersRepo.add(LimitOrder(
                  id: 0,
                  currencyFrom: from,
                  currencyTo: to,
                  amountFrom: amount,
                  targetRate: rate,
                  isAbove: isAbove,
                  createdAt: DateTime.now(),
                ));
                _loadAlertsAndOrders();
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}
