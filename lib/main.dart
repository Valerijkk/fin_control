import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/db.dart';

void main() => runApp(const FinControlRoot());

/// ==== Навигация ====
final routeObserver = RouteObserver<PageRoute<dynamic>>();

class Routes {
  static const welcome = '/';
  static const shell = '/home';
  static const add = '/add';
  static const settings = '/settings';
}

/// ==== Модель ====
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome;

  const Expense({
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

/// ==== Состояние приложения (с SQLite) ====
class AppState extends ChangeNotifier {
  final List<Expense> _items = [];
  final AppDatabase _db = AppDatabase();

  List<Expense> get items => List.unmodifiable(_items);

  // для Undo
  Expense? _lastRemoved;
  int? _lastIndex;

  /// Загрузка при старте
  Future<void> load() async {
    _items.clear();
    final rows = await _db.getAllRaw();
    for (final r in rows) {
      _items.add(
        Expense(
          id: (r['id'] as String),
          title: (r['title'] as String),
          amount: (r['amount'] as num).toDouble(),
          category: (r['category'] as String),
          date: DateTime.fromMillisecondsSinceEpoch((r['date'] as int)),
          isIncome: ((r['is_income'] as int) == 1),
        ),
      );
    }
    notifyListeners();
  }

  Future<void> add(Expense e) async {
    _items.insert(0, e);
    notifyListeners();
    await _db.insertRaw({
      'id': e.id,
      'title': e.title,
      'amount': e.amount,
      'category': e.category,
      'date': e.date.millisecondsSinceEpoch,
      'is_income': e.isIncome ? 1 : 0,
    });
  }

  Future<void> update(String id, Expense e) async {
    final i = _items.indexWhere((x) => x.id == id);
    if (i == -1) return;
    _items[i] = e;
    notifyListeners();
    await _db.updateRaw(id, {
      'id': e.id,
      'title': e.title,
      'amount': e.amount,
      'category': e.category,
      'date': e.date.millisecondsSinceEpoch,
      'is_income': e.isIncome ? 1 : 0,
    });
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _items.length) return;
    _lastRemoved = _items.removeAt(index);
    _lastIndex = index;
    notifyListeners();
    if (_lastRemoved != null) {
      await _db.deleteById(_lastRemoved!.id);
    }
  }

  /// Возврат последнего удаления (из SnackBar)
  Future<bool> undoLastRemove() async {
    if (_lastRemoved == null || _lastIndex == null) return false;
    final i = (_lastIndex!).clamp(0, _items.length);
    final e = _lastRemoved!;
    _items.insert(i, e);
    _lastRemoved = null;
    _lastIndex = null;
    notifyListeners();
    await _db.insertRaw({
      'id': e.id,
      'title': e.title,
      'amount': e.amount,
      'category': e.category,
      'date': e.date.millisecondsSinceEpoch,
      'is_income': e.isIncome ? 1 : 0,
    });
    return true;
  }
}

/// ==== InheritedNotifier для доступа к состоянию ====
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState notifier, required Widget child})
      : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

/// ==== Корень + темы + маршруты ====
class FinControlRoot extends StatefulWidget {
  const FinControlRoot({super.key});
  @override
  State<FinControlRoot> createState() => _FinControlRootState();
}

class _FinControlRootState extends State<FinControlRoot> {
  final _state = AppState();
  ThemeMode _mode = ThemeMode.light;
  bool _loaded = false;

  void _toggleTheme() =>
      setState(() => _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _state.load(); // тянем из SQLite
    if (mounted) setState(() => _loaded = true);
  }

  Route<dynamic> _onGenerateRoute(RouteSettings s) {
    final name = s.name ?? Routes.welcome;
    switch (name) {
      case Routes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen(), settings: s);
      case Routes.shell:
        return MaterialPageRoute(builder: (_) => const ShellScreen(), settings: s);
      case Routes.add:
        final initial = s.arguments is Expense ? s.arguments as Expense? : null;
        return MaterialPageRoute(builder: (_) => AddEditScreen(initial: initial), settings: s);
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen(), settings: s);
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Not found'))),
          settings: s,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // провайдеры кладём через builder, чтобы быть над Navigator
    return MaterialApp(
      title: 'FinControl',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      navigatorObservers: [routeObserver],
      onGenerateRoute: _onGenerateRoute,
      initialRoute: Routes.welcome,
      builder: (context, child) {
        if (!_loaded) {
          return Theme(
            data: _buildLightTheme(),
            child: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return AppScope(
          notifier: _state,
          child: _ThemeController(
            mode: _mode,
            toggle: _toggleTheme,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

/// ==== Тема ====
class _ThemeController extends InheritedWidget {
  final ThemeMode mode;
  final VoidCallback toggle;
  const _ThemeController({required this.mode, required this.toggle, required super.child});

  static _ThemeController of(BuildContext c) {
    final ctrl = c.dependOnInheritedWidgetOfExactType<_ThemeController>();
    assert(ctrl != null, 'ThemeController not found above MaterialApp routes');
    return ctrl!;
  }

  @override
  bool updateShouldNotify(covariant _ThemeController old) => old.mode != mode;
}

ThemeData _buildLightTheme() {
  final base = ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF6750A4));
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      titleLarge: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      titleMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: const TextStyle(fontSize: 16),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    // ↓↓↓ ключевые фиксы
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: base.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: base.colorScheme.surfaceVariant,
      labelStyle: TextStyle(color: base.colorScheme.onSurface),
      hintStyle: TextStyle(color: base.colorScheme.onSurfaceVariant),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: base.colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: base.colorScheme.primary, width: 2),
      ),
    ),
  );
}

ThemeData _buildDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF6750A4),
    brightness: Brightness.dark,
  );
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      titleLarge: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      titleMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: const TextStyle(fontSize: 16),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: base.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: base.colorScheme.surfaceVariant,
      labelStyle: TextStyle(color: base.colorScheme.onSurface),
      hintStyle: TextStyle(color: base.colorScheme.onSurfaceVariant),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: base.colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: base.colorScheme.primary, width: 2),
      ),
    ),
  );
}

/// ==== Экраны ====
/// Welcome
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppBarTitle(title: 'Добро пожаловать', actions: const [_ThemeAction()]),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('FinControl', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Калькулятор и учёт расходов', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              _PrimaryButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.shell),
                label: 'Начать',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shell (Home/Stats)
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});
  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> with RouteAware {
  int _index = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [const HomeScreen(), const StatsScreen()];
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

/// Home
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _filter;

  double _total(AppState s) =>
      s.items.fold(0.0, (sum, e) => sum + (e.isIncome ? -e.amount : e.amount));

  Iterable<Expense> _visible(AppState s) =>
      _filter == null ? s.items : s.items.where((e) => e.category == _filter);

  Future<void> _quickAddBottomSheet(AppState s) async {
    final amountCtrl = TextEditingController();
    String category = kCategories.first;
    final res = await showModalBottomSheet<Expense>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface, // контрастный фон для обеих тем
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Быстрая запись',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: const InputDecoration(labelText: 'Сумма', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Категория', border: OutlineInputBorder()),
                child: DropdownButtonHideUnderline(
                  child: StatefulBuilder(
                    builder: (ctx, setSheetState) => DropdownButton<String>(
                      isExpanded: true,
                      value: category,
                      items: [for (final c in kCategories) DropdownMenuItem(value: c, child: Text(c))],
                      onChanged: (v) => setSheetState(() => category = v ?? category),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _PrimaryButton(
                label: 'Добавить',
                icon: Icons.check,
                onPressed: () {
                  final x = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0.0;
                  if (x <= 0) return Navigator.pop(ctx);
                  final now = DateTime.now();
                  Navigator.pop(
                    ctx,
                    Expense(
                      id: 'e${now.microsecondsSinceEpoch}',
                      title: 'Быстрое добавление',
                      amount: x,
                      category: category,
                      date: now,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
    if (res != null) await s.add(res);
  }

  Future<bool> _confirmDelete(String title) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить запись?'),
        content: Text('«$title» будет удалена безвозвратно.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
        ],
      ),
    ) ??
        false;
  }

  void _showUndoSnack(AppState s, {required Expense removed, required int index}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Удалено: ${removed.title}'),
        action: SnackBarAction(
          label: 'ОТМЕНА',
          onPressed: () async {
            await s.undoLastRemove();
            try {
              await HapticFeedback.mediumImpact();
            } catch (_) {}
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return Scaffold(
      appBar: _AppBarTitle(title: 'Мои расходы', actions: const [_ThemeAction(), _SettingsAction()]),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'quick',
            tooltip: 'Быстрая запись',
            onPressed: () => _quickAddBottomSheet(s),
            child: const Icon(Icons.flash_on),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'main',
            tooltip: 'Новая запись',
            onPressed: () async {
              final e = await Navigator.of(context).pushNamed(Routes.add) as Expense?;
              if (e != null) await s.add(e);
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SummaryCard(total: _total(s)),
          ),
          const SizedBox(height: 8),
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
                ...kCategories.map(
                      (c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: _filter == c,
                      onSelected: (_) => setState(() => _filter = c),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: s.items.isEmpty
                ? const Center(child: Text('Нет записей'))
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _visible(s).length,
              itemBuilder: (_, i) {
                final e = _visible(s).elementAt(i);
                final realIndex = s.items.indexOf(e);
                return Dismissible(
                  key: ValueKey(e.id),
                  background: _dismissBg(left: true),
                  secondaryBackground: _dismissBg(left: false),
                  confirmDismiss: (_) async => await _confirmDelete(e.title),
                  onDismissed: (_) async {
                    final removed = e;
                    await s.removeAt(realIndex);
                    _showUndoSnack(s, removed: removed, index: realIndex);
                  },
                  child: InkWell(
                    onTap: () async {
                      final updated =
                      await Navigator.of(context).pushNamed(Routes.add, arguments: e) as Expense?;
                      if (updated != null) await s.update(e.id, updated);
                    },
                    child: _ExpenseTile(expense: e, outlineColor: outline),
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

  Widget _dismissBg({required bool left}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.only(left: left ? 16 : 0, right: left ? 0 : 16),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}

/// Add/Edit
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
      appBar: const _AppBarTitle(title: 'Запись', canPop: true, actions: [_ThemeAction()]),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
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
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите название' : null,
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Категория', border: OutlineInputBorder()),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _category,
                      items: [for (final c in kCategories) DropdownMenuItem(value: c, child: Text(c))],
                      onChanged: (v) => setState(() => _category = v ?? _category),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _PrimaryButton(
                  onPressed: _save,
                  label: isEdit ? 'Сохранить изменения' : 'Сохранить',
                  icon: Icons.save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stats
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final byCat = <String, double>{for (final c in kCategories) c: 0.0};
    for (final e in s.items) {
      final sign = e.isIncome ? -1.0 : 1.0;
      byCat[e.category] = (byCat[e.category] ?? 0.0) + sign * e.amount;
    }
    final maxVal =
    (byCat.values.isEmpty ? 0.0 : byCat.values.reduce((a, b) => a > b ? a : b)).abs();

    return Scaffold(
      appBar: const _AppBarTitle(title: 'Статистика', actions: [_ThemeAction()]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final entry in byCat.entries)
              _BarRow(label: entry.key, value: entry.value, maxAbs: maxVal),
            const SizedBox(height: 16),
            Text(
              'Всего расходов: ${_money(s.items.where((e) => !e.isIncome).fold(0.0, (s2, e) => s2 + e.amount))}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = _ThemeController.of(context);
    final isDark = ctrl.mode == ThemeMode.dark;
    return Scaffold(
      appBar: const _AppBarTitle(title: 'Настройки', canPop: true, actions: [_ThemeAction()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: isDark,
            onChanged: (_) => ctrl.toggle(),
            title: const Text('Тёмная тема'),
            subtitle: const Text('Переключить оформление приложения'),
          ),
          const Divider(),
          const ListTile(
            title: Text('О приложении'),
            subtitle: Text('FinControl — учебный прототип учёта расходов.'),
          ),
        ],
      ),
    );
  }
}

/// ==== UI-компоненты ====
class _AppBarTitle extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final bool canPop;
  const _AppBarTitle({required this.title, this.actions = const [], this.canPop = false});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(leading: canPop ? const BackButton() : null, title: Text(title), actions: actions);
  }
}

class _ThemeAction extends StatelessWidget {
  const _ThemeAction();
  @override
  Widget build(BuildContext context) {
    final ctrl = _ThemeController.of(context);
    final isDark = ctrl.mode == ThemeMode.dark;
    return IconButton(
      tooltip: 'Переключить тему',
      onPressed: ctrl.toggle,
      icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined),
    );
  }
}

class _SettingsAction extends StatelessWidget {
  const _SettingsAction();
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Настройки',
      onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
      icon: const Icon(Icons.settings_outlined),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  const _PrimaryButton({super.key, required this.onPressed, required this.label, this.icon});
  @override
  Widget build(BuildContext context) {
    final child = Text(label);
    return icon == null
        ? FilledButton(onPressed: onPressed, child: child)
        : FilledButton.icon(onPressed: onPressed, icon: Icon(icon), label: child);
  }
}

class _SummaryCard extends StatelessWidget {
  final double total;
  const _SummaryCard({required this.total});
  @override
  Widget build(BuildContext context) {
    final isOk = total <= 0;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 28, color: isOk ? Colors.green : Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Итоги сегодня', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                (total > 0 ? '— ' : '+ ') + _money(total.abs()),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isOk ? Colors.green : Colors.red),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final Color outlineColor;
  const _ExpenseTile({required this.expense, required this.outlineColor});
  @override
  Widget build(BuildContext context) {
    final color = expense.isIncome ? Colors.green : Colors.red;
    final sign = expense.isIncome ? '+ ' : '- ';
    final onSurfaceVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(.12),
            child: Text(expense.category.characters.first.toUpperCase(), style: TextStyle(color: color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(_formatDate(expense.date), style: TextStyle(color: onSurfaceVar)),
            ]),
          ),
          Text('$sign${_money(expense.amount)}', style: TextStyle(fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double value;   // сумма по категории
  final double maxAbs;  // для нормирования ширины
  const _BarRow({required this.label, required this.value, required this.maxAbs});

  @override
  Widget build(BuildContext context) {
    final width = maxAbs == 0.0 ? 0.0 : (value.abs() / maxAbs);
    final color = value >= 0 ? Colors.red : Colors.green;
    final outlineVar = Theme.of(context).colorScheme.outlineVariant;
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
                color: outlineVar.withOpacity(0.35),
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
          SizedBox(width: 80, child: Text(_money(value.abs().toDouble()), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

/// ==== Утилиты ====
String _money(double x) => '${x.toStringAsFixed(0)} ₽';
String _formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year} • ${two(d.hour)}:${two(d.minute)}';
}
