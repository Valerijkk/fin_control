import 'package:flutter/material.dart';
import '../../core/formatters.dart';
import '../../domain/models/expense.dart';

class SummaryCard extends StatelessWidget {
  final List<Expense> items; // уже отфильтрованные/видимые на экране
  const SummaryCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final expenses = items.where((e) => !e.isIncome).fold<double>(0, (s, e) => s + e.amount);
    final incomes = items.where((e) => e.isIncome).fold<double>(0, (s, e) => s + e.amount);
    final net = expenses - incomes;
    final isOk = net <= 0;

    Color tr(bool ok) => ok ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 28, color: tr(isOk)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Итоги', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: Text('Расходы', style: Theme.of(context).textTheme.bodyMedium)),
                  Text('— ${money(expenses)}', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(child: Text('Доходы', style: Theme.of(context).textTheme.bodyMedium)),
                  Text('+ ${money(incomes)}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700)),
                ],
              ),
              const Divider(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Итог',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    (net > 0 ? '— ' : '+ ') + money(net.abs()),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: tr(isOk)),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
