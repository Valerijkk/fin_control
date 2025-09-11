import 'package:flutter/material.dart';

void main() => runApp(const FinControlApp());

class FinControlApp extends StatelessWidget {
  const FinControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinControl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6750A4),
        brightness: Brightness.light,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.isIncome = false,
  });

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    bool? isIncome,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}

const kCategories = ['Еда', 'Транспорт', 'Дом', 'Досуг', 'Другое'];

/// ----------------- Welcome -----------------
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('FinControl',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Калькулятор и учёт расходов',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ShellScreen()),
                  );
                },
                child: const Text('Начать'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ----------------- Shell с вкладками (Home/Статистика) -----------------
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  // общие данные приложения
  final List<Expense> _items = [
    Expense(
        id: 'e1',
        title: 'Продукты',
        amount: 750,
        category: 'Еда',
        date: DateTime.now()),
    Expense(
        id: 'e2',
        title: 'Такси',
        amount: 320,
        category: 'Транспорт',
        date: DateTime.now()),
    Expense(
        id: 'e3',
        title: 'Зарплата',
        amount: 50000,
        category: 'Другое',
        isIncome: true,
        date: DateTime.now()),
  ];

  void _add(Expense e) => setState(() => _items.insert(0, e));
  void _update(String id, Expense e) {
    final i = _items.indexWhere((x) => x.id == id);
    if (i != -1) setState(() => _items[i] = e);
  }

  void _remove(String id) {
    final i = _items.indexWhere((x) => x.id == id);
    if (i != -1) setState(() => _items.removeAt(i));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        items: _items,
        onAdd: _add,
        onUpdate: _update,
        onRemove: _remove,
      ),
      StatsScreen(items: _items),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Список'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Статистика'),
        ],
      ),
    );
  }
}

/// ----------------- Home: список, фильтр, FAB -----------------
class HomeScreen extends StatefulWidget {
  final List<Expense> items;
  final void Function(Expense e) onAdd;
  final void Function(String id, Expense e) onUpdate;
  final void Function(String id) onRemove;

  const HomeScreen({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _filter; // категория

  double get _total =>
      widget.items.fold(0.0, (s, e) => s + (e.isIncome ? -e.amount : e.amount));

  Iterable<Expense> get _visible => _filter == null
      ? widget.items
      : widget.items.where((e) => e.category == _filter);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои расходы')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final e = await Navigator.of(context).push<Expense>(
            MaterialPageRoute(builder: (_) => const AddEditScreen()),
          );
          if (e != null) widget.onAdd(e);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _SummaryCard(total: _total),
          ),
          // Фильтр по категориям
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Все'),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
                const SizedBox(width: 8),
                ...kCategories.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: _filter == c,
                    onSelected: (_) => setState(() => _filter = c),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _visible.isEmpty
                ? const Center(child: Text('Нет записей'))
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _visible.length,
              itemBuilder: (_, i) {
                final e = _visible.elementAt(i);
                return Dismissible(
                  key: ValueKey(e.id),
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    widget.onRemove(e.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Удалено: ${e.title}')),
                    );
                  },
                  child: InkWell(
                    onTap: () async {
                      final updated = await Navigator.of(context)
                          .push<Expense>(MaterialPageRoute(
                        builder: (_) => AddEditScreen(initial: e),
                      ));
                      if (updated != null) {
                        widget.onUpdate(e.id, updated);
                      }
                    },
                    child: _ExpenseTile(expense: e),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double total;
  const _SummaryCard({required this.total});

  @override
  Widget build(BuildContext context) {
    final isOk = total <= 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 28,
            color: isOk ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Итоги сегодня', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  (total > 0 ? '— ' : '+ ') + _money(total.abs()),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isOk ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final color = expense.isIncome ? Colors.green : Colors.red;
    final sign = expense.isIncome ? '+ ' : '- ';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(.12),
            child: Text(
              expense.category.characters.first.toUpperCase(),
              style: TextStyle(color: color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(_formatDate(expense.date), style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Text(
            '$sign${_money(expense.amount)}',
            style: TextStyle(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

/// ----------------- Add/Edit форма -----------------
class AddEditScreen extends StatefulWidget {
  final Expense? initial;
  const AddEditScreen({super.key, this.initial});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  String _category = kCategories.first;
  bool _isIncome = false;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _title.text = i.title;
      _amount.text = i.amount.toStringAsFixed(0);
      _category = i.category;
      _isIncome = i.isIncome;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    if (_form.currentState?.validate() != true) return;
    final amount = double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0.0;
    final now = DateTime.now();

    final e = (widget.initial ??
        Expense(
          id: 'e${now.microsecondsSinceEpoch}',
          title: '',
          amount: 0.0,
          category: _category,
          date: now,
          isIncome: _isIncome,
        ))
        .copyWith(
      title: _title.text.trim(),
      amount: amount,
      category: _category,
      date: now,
      isIncome: _isIncome,
    );

    Navigator.of(context).pop(e);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Редактировать' : 'Новая запись')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: ListView(
              children: [
                SwitchListTile(
                  value: _isIncome,
                  onChanged: (v) => setState(() => _isIncome = v),
                  title: const Text('Это доход'),
                  subtitle: const Text('Вычитается из итоговых расходов'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amount,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Сумма',
                    hintText: '0',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final x = double.tryParse((v ?? '').replaceAll(',', '.'));
                    if (x == null || x <= 0) return 'Введите сумму > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    hintText: 'Например, Продукты',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введите название' : null,
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Категория',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _category,
                      items: [
                        for (final c in kCategories)
                          DropdownMenuItem(value: c, child: Text(c))
                      ],
                      onChanged: (v) => setState(() => _category = v ?? _category),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: Text(isEdit ? 'Сохранить изменения' : 'Сохранить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ----------------- Статистика (простая) -----------------
class StatsScreen extends StatelessWidget {
  final List<Expense> items;
  const StatsScreen({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final byCat = <String, double>{};
    for (final c in kCategories) {
      byCat[c] = 0.0;
    }
    for (final e in items) {
      final sign = e.isIncome ? -1.0 : 1.0; // double!
      byCat[e.category] = (byCat[e.category] ?? 0.0) + sign * e.amount;
    }
    final maxVal =
    (byCat.values.isEmpty ? 0.0 : byCat.values.reduce((a, b) => a > b ? a : b))
        .abs();

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final entry in byCat.entries)
              _BarRow(label: entry.key, value: entry.value, maxAbs: maxVal),
            const SizedBox(height: 16),
            Text(
              'Всего расходов: ${_money(items.where((e) => !e.isIncome).fold(0.0, (s, e) => s + e.amount))}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double value;
  final double maxAbs;

  const _BarRow({required this.label, required this.value, required this.maxAbs});

  @override
  Widget build(BuildContext context) {
    final width = maxAbs == 0.0 ? 0.0 : (value.abs() / maxAbs);
    final color = value >= 0 ? Colors.red : Colors.green; // расходы красные, доходы зелёные
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 92, child: Text(label)),
          Expanded(
            child: Container(
              height: 12,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                widthFactor: width.clamp(0.0, 1.0).toDouble(),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              _money(value.abs().toDouble()),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// --------------- Утилиты форматирования ---------------
String _money(double x) => '${x.toStringAsFixed(0)} ₽';

String _formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year} • ${two(d.hour)}:${two(d.minute)}';
}
