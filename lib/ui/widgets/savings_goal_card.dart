// Карточка цели накопления (как в инвестиционных приложениях).
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../domain/models/savings_goal.dart';
import '../../domain/repositories/savings_goal_repository.dart';
import '../../domain/repositories/portfolio_repository.dart';

class SavingsGoalCard extends StatefulWidget {
  const SavingsGoalCard({super.key});

  @override
  State<SavingsGoalCard> createState() => _SavingsGoalCardState();
}

class _SavingsGoalCardState extends State<SavingsGoalCard> {
  final SavingsGoalRepository _goalRepo = SavingsGoalRepository();
  final PortfolioRepository _portfolioRepo = PortfolioRepository();
  List<SavingsGoal> _goals = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _goalRepo.getAll();
    if (!mounted) return;
    // ignore: use_build_context_synchronously
    setState(() => _goals = list);
  }

  Future<void> _addGoal() async {
    final titleCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '100000');
    final base = await _portfolioRepo.getBaseCurrency();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новая цель накопления'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              maxLength: 50,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: targetCtrl,
              maxLength: 15,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Цель ($base)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              final target = double.tryParse(targetCtrl.text.trim().replaceFirst(',', '.'));
              if (title.isEmpty || target == null || target <= 0) return;
              Navigator.pop(ctx, {'title': title, 'target': target});
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
    if (result == null) return;
    await _goalRepo.add(SavingsGoal(
      id: 0,
      title: result['title'] as String,
      targetAmount: result['target'] as double,
      baseCurrency: base,
      currentAmount: 0,
      createdAt: DateTime.now(),
    ));
    _load();
  }

  Future<void> _topUp(SavingsGoal goal) async {
    final amountCtrl = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Пополнить: ${goal.title}'),
        content: TextField(
          controller: amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'Сумма (${goal.baseCurrency})'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(amountCtrl.text.trim().replaceFirst(',', '.'));
              if (v == null || v <= 0) return;
              Navigator.pop(ctx, v);
            },
            child: const Text('Пополнить'),
          ),
        ],
      ),
    );
    if (result == null) return;
    await _goalRepo.updateCurrentAmount(goal.id, goal.currentAmount + result);
    _load();
  }

  Future<void> _syncFromPortfolio(SavingsGoal goal) async {
    final balance = await _portfolioRepo.getBalance();
    await _goalRepo.updateCurrentAmount(goal.id, balance);
    if (!mounted) return;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('##0', 'ru_RU');
    if (_goals.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.cardContentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Цель накопления', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              const Text('Откладывайте деньги и отслеживайте прогресс.'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _addGoal,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Добавить цель'),
              ),
            ],
          ),
        ),
      );
    }
    final goal = _goals.first;
    final progress = goal.progressPercent.clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.cardContentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(goal.title, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  '${fmt.format(goal.progressPercent)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${fmt.format(goal.currentAmount)} / ${fmt.format(goal.targetAmount)} ${goal.baseCurrency}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
            ),
            if (goal.deadline != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'До ${DateFormat('dd.MM.yyyy').format(goal.deadline!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => _topUp(goal),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Пополнить'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _syncFromPortfolio(goal),
                  child: const Text('Из портфеля'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
