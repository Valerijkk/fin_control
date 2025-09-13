import 'package:flutter/material.dart';
import '../../../domain/models/expense.dart';
import '../../../core/formatters.dart';
import '../../../core/routes.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  const ExpenseTile({super.key, required this.expense});
  @override
  Widget build(BuildContext context) {
    final color = expense.isIncome ? Colors.green : Colors.red;
    final sign = expense.isIncome ? '+ ' : '- ';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(.12),
            child: Text(expense.category.characters.first.toUpperCase(),
                style: TextStyle(color: color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
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
                ],
              ),
              const SizedBox(height: 2),
              Text(formatDate(expense.date), style: const TextStyle(color: Colors.black54)),
            ]),
          ),
          Text('$sign${money(expense.amount)}',
              style: TextStyle(fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
