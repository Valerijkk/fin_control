import 'package:intl/intl.dart';

final _numRu = NumberFormat.decimalPattern('ru_RU');

String money(double x) => '${_numRu.format(x.round())} ₽';

String formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year} • ${two(d.hour)}:${two(d.minute)}';
}

String shortDayHeader(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dd = DateTime(d.year, d.month, d.day);

  if (dd == today) return 'Сегодня';
  if (dd == today.subtract(const Duration(days: 1))) return 'Вчера';
  return DateFormat('d MMMM yyyy', 'ru_RU').format(dd); // например, 2 января 2025
}

bool isWithinDays(DateTime date, int days) {
  final now = DateTime.now();
  final from = now.subtract(Duration(days: days));
  return date.isAfter(from) || _sameDay(date, from);
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
