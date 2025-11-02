import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_scope.dart';
import '../../state/app_state.dart';
import '../../core/categories.dart';
import '../../core/routes.dart';
import '../../core/formatters.dart';
import '../../domain/models/expense.dart';
import '../../services/rates_api.dart';

import '../widgets/app_bar_title.dart';
import '../widgets/primary_button.dart';
import '../widgets/settings_action.dart';
import '../widgets/summary_card.dart';
import '../widgets/expense_tile.dart';
import '../widgets/rates_card.dart';
import '../widgets/theme_action.dart';

enum _DateFilter { all, today, d7, d30 }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _categoryFilter;
  _DateFilter _dateFilter = _DateFilter.all;
  String _query = '';
  late final Future<Rates> _ratesFuture;

  @override
  void initState() {
    super.initState();
    _ratesFuture = RatesApi.fetch();
  }

  Iterable<Expense> _filterVisible(AppState s) {
    Iterable<Expense> x = s.items;

    if (_categoryFilter != null) {
      x = x.where((e) => e.category == _categoryFilter);
    }

    if (_dateFilter != _DateFilter.all) {
      x = x.where((e) {
        switch (_dateFilter) {
          case _DateFilter.today:
            return isWithinDays(e.date, 0);
          case _DateFilter.d7:
            return isWithinDays(e.date, 7);
          case _DateFilter.d30:
            return isWithinDays(e.date, 30);
          case _DateFilter.all:
            return true;
        }
      });
    }

    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      x = x.where((e) => e.title.toLowerCase().contains(q));
    }

    return x;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final cats = s.categories;
    final visible = _filterVisible(s).toList();
    final grouped = _groupByDay(visible);

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
          // Поиск
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Поиск по названию…',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 8),
          // Итоги по выборке
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SummaryCard(items: visible),
          ),
          const SizedBox(height: 8),
          // Фильтры: категория + период + добавить
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Все категории'),
                  selected: _categoryFilter == null,
                  onSelected: (_) => setState(() => _categoryFilter = null),
                ),
                const SizedBox(width: 8),
                ...cats.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: _categoryFilter == c,
                    onSelected: (_) => setState(() => _categoryFilter = c),
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: ActionChip(
                    avatar: const Icon(Icons.add),
                    label: const Text('Категория'),
                    onPressed: () async {
                      final created = await _askNewCategory(context, s);
                      if (created != null) setState(() => _categoryFilter = created);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                _periodChip(_DateFilter.all, 'Все'),
                const SizedBox(width: 8),
                _periodChip(_DateFilter.today, 'Сегодня'),
                const SizedBox(width: 8),
                _periodChip(_DateFilter.d7, '7 дней'),
                const SizedBox(width: 8),
                _periodChip(_DateFilter.d30, '30 дней'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Список
          Expanded(
            child: grouped.isEmpty
                ? const Center(child: Text('Нет записей'))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: grouped.length,
              itemBuilder: (_, i) {
                final entry = grouped[i];
                if (entry is _Header) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(entry.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  );
                } else if (entry is _RowItem) {
                  final e = entry.expense;
                  final realIndex = s.items.indexOf(e);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Dismissible(
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
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodChip(_DateFilter f, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _dateFilter == f,
      onSelected: (_) => setState(() => _dateFilter = f),
    );
  }

  List<_Entry> _groupByDay(List<Expense> list) {
    if (list.isEmpty) return const [];

    list.sort((a, b) => b.date.compareTo(a.date));
    final entries = <_Entry>[];
    DateTime? currentDay;

    for (final e in list) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      if (currentDay == null || d != currentDay) {
        entries.add(_Header(shortDayHeader(e.date)));
        currentDay = d;
      }
      entries.add(_RowItem(e));
    }
    return entries;
  }

  Future<void> _quickAddBottomSheet(AppState s) async {
    final amountCtrl = TextEditingController();
    String category = s.categories.first;
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
                      items: [
                        for (final c in s.categories) DropdownMenuItem(value: c, child: Text(c)),
                        const DropdownMenuItem(
                          value: '__add__',
                          child: Row(children: [Icon(Icons.add, size: 18), SizedBox(width: 8), Text('Добавить категорию…')]),
                        ),
                      ],
                      onChanged: (v) async {
                        if (v == '__add__') {
                          final created = await _askNewCategory(ctx, s);
                          if (created != null) {
                            setSheetState(() => category = created);
                          }
                        } else {
                          setSheetState(() => category = v ?? category);
                        }
                      },
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

  Future<String?> _askNewCategory(BuildContext context, AppState state) async {
    final ctrl = TextEditingController();
    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Новая категория'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Например, Здоровье'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Добавить')),
        ],
      ),
    );
    if (res == null || res.trim().isEmpty) return null;
    final created = await state.addCategory(res);
    return created;
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

sealed class _Entry {}
class _Header extends _Entry {
  final String title;
  _Header(this.title);
}
class _RowItem extends _Entry {
  final Expense expense;
  _RowItem(this.expense);
}
