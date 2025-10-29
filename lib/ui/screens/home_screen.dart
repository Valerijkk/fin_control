import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/categories.dart';
import '../../core/formatters.dart';
import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../domain/models/expense.dart';
import '../../services/rates_api.dart';
import '../../state/app_scope.dart';
import '../../state/app_state.dart';

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
  late Future<Rates> _ratesFuture;

  @override
  void initState() {
    super.initState();
    _ratesFuture = RatesApi.fetch();
  }

  void _reloadRates() => setState(() => _ratesFuture = RatesApi.fetch());

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
    final l10n = context.l10n;
    final s = AppScope.of(context);
    final cats = s.categories;
    final visible = _filterVisible(s).toList();
    final grouped = _groupByDay(l10n, visible);

    return Scaffold(
      appBar: AppBarTitle(title: l10n.homeTitle, actions: const [ThemeAction(), SettingsAction()]),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'quick',
            tooltip: l10n.homeQuickEntryTooltip,
            onPressed: () => _quickAddBottomSheet(s),
            child: const Icon(Icons.flash_on),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'main',
            tooltip: l10n.homeNewEntryTooltip,
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
            child: RatesCard(future: _ratesFuture, onReload: _reloadRates),
          ),
          const SizedBox(height: 8),
          // Поиск
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.homeSearchHint,
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
                  label: Text(l10n.homeAllCategories),
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
                    label: Text(l10n.homeCreateCategoryAction),
                    onPressed: () async {
                      final created = await _askNewCategory(context, s);
                      if (created != null) setState(() => _categoryFilter = created);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                _periodChip(_DateFilter.all, l10n.homePeriodAll),
                const SizedBox(width: 8),
                _periodChip(_DateFilter.today, l10n.homePeriodToday),
                const SizedBox(width: 8),
                _periodChip(_DateFilter.d7, l10n.homePeriod7Days),
                const SizedBox(width: 8),
                _periodChip(_DateFilter.d30, l10n.homePeriod30Days),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Список
          Expanded(
            child: grouped.isEmpty
                ? Center(child: Text(l10n.homeEmptyState))
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

  List<_Entry> _groupByDay(AppLocalizations l10n, List<Expense> list) {
    if (list.isEmpty) return const [];

    list.sort((a, b) => b.date.compareTo(a.date));
    final entries = <_Entry>[];
    DateTime? currentDay;

    for (final e in list) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      if (currentDay == null || d != currentDay) {
        entries.add(_Header(shortDayHeader(l10n, e.date)));
        currentDay = d;
      }
      entries.add(_RowItem(e));
    }
    return entries;
  }

  Future<void> _quickAddBottomSheet(AppState s) async {
    final amountCtrl = TextEditingController();
    String category = s.categories.isNotEmpty ? s.categories.first : '';
    final res = await showModalBottomSheet<Expense>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final sheetL10n = ctx.l10n;
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
              Text(sheetL10n.homeQuickAddTitle, style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: InputDecoration(labelText: sheetL10n.homeAmountLabel),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: InputDecoration(labelText: sheetL10n.homeCategoryLabel),
                child: DropdownButtonHideUnderline(
                  child: StatefulBuilder(
                    builder: (ctx, setSheetState) => DropdownButton<String>(
                      isExpanded: true,
                      value: category.isEmpty ? null : category,
                      items: [
                        for (final c in s.categories) DropdownMenuItem(value: c, child: Text(c)),
                        DropdownMenuItem(
                          value: '__add__',
                          child: Row(children: [
                            const Icon(Icons.add, size: 18),
                            const SizedBox(width: 8),
                            Text(sheetL10n.homeAddCategoryOption),
                          ]),
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
                label: sheetL10n.homePrimaryAdd,
                icon: Icons.check,
                onPressed: () {
                  final x = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0.0;
                  if (x <= 0 || (category.isEmpty && s.categories.isEmpty)) return Navigator.pop(ctx);
                  final now = DateTime.now();
                  Navigator.pop(
                    ctx,
                    Expense(
                      id: 'e${now.microsecondsSinceEpoch}',
                      title: sheetL10n.homeQuickAddDefaultTitle,
                      amount: x,
                      category: category.isEmpty && s.categories.isNotEmpty ? s.categories.first : category,
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
    final l10n = context.l10n;
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.homeDeleteDialogTitle),
        content: Text(l10n.homeDeleteDialogMessage(title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
        ],
      ),
    ) ??
        false;
  }

  void _showUndoSnack(AppState s, {required Expense removed, required int index}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.homeUndoMessage(removed.title)),
        action: SnackBarAction(
          label: context.l10n.homeUndoAction,
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
    final l10n = context.l10n;
    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.homeNewCategoryTitle),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.homeNewCategoryHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: Text(l10n.homeNewCategoryAdd)),
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
