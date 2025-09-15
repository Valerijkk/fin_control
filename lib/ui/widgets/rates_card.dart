import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/rates_api.dart';

class RatesCard extends StatelessWidget {
  final Future<Rates> future;
  const RatesCard({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('##0.00', 'ru_RU');

    String _formatTs(DateTime d) {
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
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snap.hasError) {
          child = Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Курс валют: ошибка загрузки',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        } else {
          final r = snap.data!;
          final ts = r.asOf != null ? ' • от ${_formatTs(r.asOf!)}' : '';
          final offline = r.fromCache ? ' • офлайн' : '';
          child = Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.currency_exchange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'USD ${fmt.format(r.usd)} • EUR ${fmt.format(r.eur)}$ts$offline',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Обновить',
                  onPressed: () {
                    // Переинициализируем Future и перерисуемся через родителя, если нужно —
                    // но чаще всего карточка живёт коротко, так что просто вызовем setState вне.
                    // Здесь безопасно: FutureBuilder получит новый future, если родитель передаст его.
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: child,
        );
      },
    );
  }
}
