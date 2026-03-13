// Экран «Статистика»: полоски по категориям (только расходы), проценты, всего расходов/доходов.
import 'package:flutter/material.dart';
import '../../state/app_scope.dart';
import '../../core/formatters.dart';
import '../widgets/app_bar_title.dart';
import '../widgets/bar_row.dart';
import '../widgets/theme_action.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);

    // Суммы расходов по категориям (только записи с isIncome == false), чтобы сумма по категориям равнялась «Всего расходов»
    final byCat = <String, double>{for (final c in s.categories) c: 0.0};
    for (final e in s.items) {
      if (e.isIncome) continue;
      if (!byCat.containsKey(e.category)) byCat[e.category] = 0.0;
      byCat[e.category] = (byCat[e.category] ?? 0.0) + e.amount;
    }

    final totalExpenses = byCat.values.fold<double>(0, (a, b) => a + b);
    final maxVal = totalExpenses > 0
        ? byCat.values.reduce((a, b) => a > b ? a : b)
        : 0.0;

    final totalIncome = s.items.where((e) => e.isIncome).fold<double>(0, (x, e) => x + e.amount);

    return Scaffold(
      appBar: const AppBarTitle(title: 'Статистика', actions: [ThemeAction()]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in byCat.entries)
              BarRow(
                label: entry.key,
                value: entry.value,
                maxAbs: maxVal,
                percent: totalExpenses > 0 && entry.value > 0 ? (entry.value / totalExpenses) : null,
              ),
            const SizedBox(height: 16),
            Text(
              'Всего расходов: ${money(totalExpenses)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (totalIncome > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Всего доходов: ${money(totalIncome)}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
