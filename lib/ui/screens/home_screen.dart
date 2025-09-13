import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../state/app_scope.dart';
import '../../state/app_state.dart';
import '../../core/categories.dart';
import '../../core/routes.dart';
import '../../domain/models/expense.dart';
import '../../services/rates_api.dart';
import '../widgets/app_bar_title.dart';
import '../widgets/primary_button.dart';
import '../widgets/settings_action.dart';
import '../widgets/summary_card.dart';
import '../widgets/expense_tile.dart';
import '../widgets/rates_card.dart';
import '../widgets/theme_action.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _filter;
  late final Future<Rates> _ratesFuture;

  @override
  void initState() {
    super.initState();
    _ratesFuture = RatesApi.fetch();
  }

  double _total(AppState s) =>
      s.items.fold(0.0, (sum, e) => sum + (e.isIncome ? -e.amount : e.amount));

  Iterable<Expense> _visible(AppState s) =>
      _filter == null ? s.items : s.items.where((e) => e.category == _filter);

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);

    return Scaffold(
      appBar: const AppBarTitle(title: 'Мои расходы', actions: [ThemeAction(), SettingsAction()]),
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
            child: RatesCard(future: _ratesFuture),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SummaryCard(total: _total(s)),
          ),
          const SizedBox(height: 8),
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
                      await Navigator.of(context).pushNamed(Routes.add, arguments: e)
                      as Expense?;
                      if (updated != null) await s.update(e.id, updated);
                    },
                    child: ExpenseTile(expense: e),
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

  Future<void> _quickAddBottomSheet(AppState s) async {
    final amountCtrl = TextEditingController();
    String category = kCategories.first;
    final res = await showModalBottomSheet<Expense>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
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
              Text('Быстрая запись', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: const InputDecoration(labelText: 'Сумма'),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Категория'),
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
              PrimaryButton(
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
