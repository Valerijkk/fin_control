import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/rates_api.dart';

class RatesCard extends StatelessWidget {
  final Future<Rates> future;
  const RatesCard({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('##0.00', 'ru_RU');
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
            child: Text('Курс валют: ошибка загрузки',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          );
        } else {
          final r = snap.data!;
          child = Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.currency_exchange),
                const SizedBox(width: 12),
                Text('USD ${fmt.format(r.usd)} • EUR ${fmt.format(r.eur)}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: child,
        );
      },
    );
  }
}
