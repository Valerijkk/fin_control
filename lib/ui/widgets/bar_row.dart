import 'package:flutter/material.dart';
import '../../core/formatters.dart';

class BarRow extends StatelessWidget {
  final String label;
  final double value;
  final double maxAbs;
  final double? percent; // 0..1

  const BarRow({
    super.key,
    required this.label,
    required this.value,
    required this.maxAbs,
    this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final width = maxAbs == 0.0 ? 0.0 : (value.abs() / maxAbs);
    final color = value >= 0 ? Colors.red : Colors.green;
    final pctText = percent != null ? ' • ${(percent! * 100).toStringAsFixed(0)}%' : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 96, child: Text(label)),
          Expanded(
            child: Container(
              height: 12,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.35),
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                widthFactor: width.clamp(0.0, 1.0).toDouble(),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text('${money(value.abs())}$pctText', textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
