import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/l10n.dart';
import '../../services/rates_api.dart';

class RatesCard extends StatelessWidget {
  final Future<Rates> future;
  final VoidCallback onReload;
  const RatesCard({super.key, required this.future, required this.onReload});

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n.localeName;
    final NumberFormat fmt;
    try {
      fmt = NumberFormat('##0.00', locale);
    } catch (_) {
      fmt = NumberFormat('##0.00');
    }

    String _formatTs(DateTime d) {
      try {
        return DateFormat.yMd(locale).add_Hm().format(d);
      } catch (_) {
        try {
          return DateFormat.yMd().add_Hm().format(d);
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
              context.l10n.ratesError,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        } else {
          final r = snap.data!;
          final ts =
              r.asOf != null ? context.l10n.ratesTimestampSuffix(_formatTs(r.asOf!)) : '';
          final offline = r.fromCache ? context.l10n.ratesOfflineSuffix : '';
          child = Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.currency_exchange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${context.l10n.ratesValue(fmt.format(r.usd), fmt.format(r.eur))}$ts$offline',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.commonRefresh,
                  onPressed: onReload,
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
