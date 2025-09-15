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

    // Суммы по категориям (расходы положительные, доходы отрицательные)
    final byCat = <String, double>{for (final c in s.categories) c: 0.0};
    for (final e in s.items) {
      if (!byCat.containsKey(e.category)) byCat[e.category] = 0.0; // вдруг категория новая
      final sign = e.isIncome ? -1.0 : 1.0;
      byCat[e.category] = (byCat[e.category] ?? 0.0) + sign * e.amount;
    }

    final maxVal =
    (byCat.values.isEmpty ? 0.0 : byCat.values.reduce((a, b) => a > b ? a : b)).abs();

    // Для процентов считаем только расходы
    final totalExpenses = s.items.where((e) => !e.isIncome).fold<double>(0, (x, e) => x + e.amount);

    return Scaffold(
      appBar: const AppBarTitle(title: 'Статистика', actions: [ThemeAction()]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
              'Всего расходов: ${money(s.items.where((e) => !e.isIncome).fold(0.0, (s, e) => s + e.amount))}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
