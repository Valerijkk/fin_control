import 'package:flutter/material.dart';

void main() => runApp(const FinControlApp());

/// Простое приложение-«калькулятор расходов» без внешних зависимостей.
/// 3 экрана: Welcome → Home → AddExpense.
/// Данные хранятся в состоянии Home экрана (in-memory).
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
      routes: {
        '/': (_) => const WelcomeScreen(),
        '/home': (_) => const HomeScreen(),
        '/add': (_) => const AddExpenseScreen(),
      },
    );
  }
}

/// Модель расхода.
class Expense {
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  Expense({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });
}

/// --- Экран 1: Welcome ---
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
              const Text(
                'FinControl',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Калькулятор и учёт расходов',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                child: const Text('Начать'),
              ),
              const SizedBox(height: 32),
              const Text('v0.1 — учебный прототип', style: TextStyle(color: Colors.black38)),
            ],
          ),
        ),
      ),
    );
  }
}

/// --- Экран 2: Home (список расходов + баланс) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Expense> _items = [
    Expense(title: 'Продукты', amount: 750, category: 'Еда', date: DateTime.now()),
    Expense(title: 'Такси', amount: 320, category: 'Транспорт', date: DateTime.now()),
    Expense(title: 'Кофе', amount: 190, category: 'Еда', date: DateTime.now()),
  ];

  double get _total => _items.fold(0.0, (sum, e) => sum + e.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои расходы')),
      body: Column(
        children: [
          // Карточка "итоги"
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _SummaryCard(total: _total),
          ),

          // Список расходов
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _items.length,
              itemBuilder: (_, i) => _ExpenseTile(expense: _items[i]),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ждём результат с экрана добавления
          final result = await Navigator.of(context).pushNamed('/add') as Expense?;
          if (result != null) {
            setState(() => _items.insert(0, result));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double total;
  const _SummaryCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Итоги за сегодня', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '— ${_money(total)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
            child: Text(expense.category.characters.first.toUpperCase()),
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
          Text('- ${_money(expense.amount)}', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// --- Экран 3: AddExpense (форма добавления) ---
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _form = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _category = 'Еда';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_form.currentState?.validate() != true) return;

    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    final exp = Expense(
      title: _titleCtrl.text.trim(),
      amount: amount,
      category: _category,
      date: DateTime.now(),
    );
    Navigator.of(context).pop(exp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новая трата')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: ListView(
              children: [
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    hintText: 'Например, Продукты',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите название' : null,
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
                      items: const [
                        DropdownMenuItem(value: 'Еда', child: Text('Еда')),
                        DropdownMenuItem(value: 'Транспорт', child: Text('Транспорт')),
                        DropdownMenuItem(value: 'Дом', child: Text('Дом')),
                        DropdownMenuItem(value: 'Досуг', child: Text('Досуг')),
                        DropdownMenuItem(value: 'Другое', child: Text('Другое')),
                      ],
                      onChanged: (v) => setState(() => _category = v ?? _category),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Сохранить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Утилиты форматирования
String _money(double x) => '${x.toStringAsFixed(0)} ₽';

String _formatDate(DateTime d) {
  final two = (int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year} • ${two(d.hour)}:${two(d.minute)}';
}
