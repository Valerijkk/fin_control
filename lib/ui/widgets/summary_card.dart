import 'package:flutter/material.dart';
import '../../../core/formatters.dart';

class SummaryCard extends StatelessWidget {
  final double total;
  const SummaryCard({super.key, required this.total});
  @override
  Widget build(BuildContext context) {
    final isOk = total <= 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 28, color: isOk ? Colors.green : Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Итоги сегодня', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                (total > 0 ? '— ' : '+ ') + money(total.abs()),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isOk ? Colors.green : Colors.red),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
