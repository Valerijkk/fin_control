// Экран «Обменник»: выбор валют, конвертация по RatesApi, история операций.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/exchange_operation.dart';
import '../../domain/repositories/exchange_repository.dart';
import '../../services/rates_api.dart' show Rates, RatesApi, kCurrencyCodes;
import '../widgets/app_bar_title.dart';
import '../widgets/theme_action.dart';
import '../widgets/settings_action.dart';

/// Список валют для выпадающих списков: RUB + все коды из API.
final _currencies = ['RUB', ...kCurrencyCodes];

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final ExchangeRepository _repo = ExchangeRepository();
  final _amountController = TextEditingController(text: '1000');
  String _currencyFrom = 'RUB';
  String _currencyTo = 'USD';
  Rates? _rates;
  Exception? _ratesError;
  List<ExchangeOperation> _history = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadRates();
    _loadHistory();
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
      if (mounted) setState(() => _rates = r);
    } catch (e) {
      if (mounted) setState(() => _ratesError = e is Exception ? e : Exception(e.toString()));
    }
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
      await _loadHistory();
      if (mounted) {
        final nf = NumberFormat('##0.00', 'ru_RU');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Обмен: ${nf.format(amount)} $_currencyFrom → ${nf.format(toAmount)} $_currencyTo')),
        );
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
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_ratesError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Курсы: ошибка загрузки',
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
                    key: const ValueKey('currency_from'),
                    initialValue: _currencyFrom,
                    items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _currencyFrom = v ?? _currencyFrom),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Сумма',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  const Text('В валюту'),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    key: const ValueKey('currency_to'),
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
                    label: Text(_loading ? 'Обмен...' : 'Обменять'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          _SectionTitle(title: 'История обменов'),
          const SizedBox(height: 10),
          if (_history.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Пока нет операций')),
              ),
            )
          else
            ..._history.take(20).map((op) {
              final d = DateFormat('dd.MM.yyyy HH:mm', 'ru_RU').format(op.createdAt);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
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
}

/// Подзаголовок секции (например «История обменов») в стиле темы.
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
