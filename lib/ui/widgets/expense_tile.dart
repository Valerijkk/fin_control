import 'package:flutter/material.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../core/categories.dart';
import '../../domain/models/expense.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  const ExpenseTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final color = expense.isIncome ? Colors.green : categoryColor(expense.category);
    final sign = expense.isIncome ? '+ ' : '- ';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(.12),
            child: Icon(categoryIcon(expense.category), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                if (expense.imagePath != null)
                  IconButton(
                    tooltip: 'Открыть фото',
                    icon: const Icon(Icons.receipt_long_outlined),
                    onPressed: () => Navigator.of(context)
                        .pushNamed(Routes.photo, arguments: expense.imagePath!),
                  ),
              ]),
              const SizedBox(height: 2),
              Text(
                '${expense.category} • ${formatDate(expense.date)}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ]),
          ),
          const SizedBox(width: 8),
          Text(
            '$sign${money(expense.amount)}',
            style: TextStyle(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
