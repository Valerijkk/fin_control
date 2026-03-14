// Карточка курсов: FutureBuilder, до 6 валют, дата, пометка «офлайн» при кэше.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../../services/rates_api.dart';

class RatesCard extends StatelessWidget {
  final Future<Rates> future;
  const RatesCard({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('##0.00', 'ru_RU');

    String formatTs(DateTime d) {
      try {
        return DateFormat('dd.MM HH:mm', 'ru_RU').format(d);
      } catch (_) {
        try {
          return DateFormat('dd.MM HH:mm').format(d);
        } catch (_) {
          return d.toIso8601String();
        }
      }
    }

    return FutureBuilder<Rates>(
      future: future,
      builder: (context, snap) {
        Widget child;
        if (snap.connectionState == ConnectionState.waiting) {
          child = const Padding(
            padding: EdgeInsets.all(AppTheme.cardContentPadding),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snap.hasError) {
          child = Padding(
            padding: const EdgeInsets.all(AppTheme.cardContentPadding),
            child: Text(
              'Ошибка загрузки курсов',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        } else {
          final r = snap.data!;
          final ts = r.asOf != null ? ' • от ${formatTs(r.asOf!)}' : '';
          final offline = r.fromCache ? ' • офлайн' : '';
          child = Padding(
            padding: const EdgeInsets.all(AppTheme.cardContentPadding),
            child: Row(
              children: [
                const Icon(Icons.currency_exchange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${r.rates.entries.take(6).map((e) => '${e.key} ${fmt.format(e.value)}').join(' • ')}$ts$offline',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Обновить',
                  onPressed: () {
                    // Обновление курсов выполняет родитель (передаёт новый future в RatesCard).
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          );
        }
        return Card(child: child);
      },
    );
  }
}
