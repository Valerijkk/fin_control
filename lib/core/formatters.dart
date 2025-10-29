import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

final _numberFormats = <String, NumberFormat>{};

NumberFormat _numFormatter(String locale) =>
    _numberFormats.putIfAbsent(locale, () => NumberFormat.decimalPattern(locale));

String money(double x) {
  final locale = Intl.getCurrentLocale().isEmpty ? 'en' : Intl.getCurrentLocale();
  return '${_numFormatter(locale).format(x.round())} ₽';
}

String formatDate(DateTime d, {String? locale}) {
  final loc = (locale != null && locale.isNotEmpty)
      ? locale
      : (Intl.getCurrentLocale().isEmpty ? 'en' : Intl.getCurrentLocale());
  try {
    final date = DateFormat.yMd(loc).format(d);
    final time = DateFormat.Hm(loc).format(d);
    return '$date • $time';
  } catch (_) {
    final date = DateFormat.yMd().format(d);
    final time = DateFormat.Hm().format(d);
    return '$date • $time';
  }
}

String shortDayHeader(AppLocalizations l10n, DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dd = DateTime(d.year, d.month, d.day);

  if (dd == today) return l10n.today;
  if (dd == today.subtract(const Duration(days: 1))) return l10n.yesterday;
  try {
    return DateFormat.yMMMMd(l10n.localeName).format(dd);
  } catch (_) {
    return DateFormat.yMMMMd().format(dd);
  }
}

bool isWithinDays(DateTime date, int days) {
  final now = DateTime.now();
  final from = now.subtract(Duration(days: days));
  return date.isAfter(from) || _sameDay(date, from);
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
