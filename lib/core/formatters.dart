// Форматирование чисел и дат для отображения в UI (русская локаль).
import 'package:intl/intl.dart';

/// Форматтер чисел в русской локали (разделители тысяч и т.д.).
final _numRu = NumberFormat.decimalPattern('ru_RU');

/// Форматирует сумму в рубли: округляет до целого и добавляет символ ₽.
/// Пример: money(12.34) → "12 ₽".
String money(double x) => '${_numRu.format(x.round())} ₽';

/// Форматирует дату и время в виде "ДД.ММ.ГГГГ • ЧЧ:ММ".
String formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year} • ${two(d.hour)}:${two(d.minute)}';
}

/// Краткий заголовок для дня: "Сегодня", "Вчера" или полная дата (например "2 января 2025").
String shortDayHeader(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dd = DateTime(d.year, d.month, d.day);

  if (dd == today) return 'Сегодня';
  if (dd == today.subtract(const Duration(days: 1))) return 'Вчера';
  return DateFormat('d MMMM yyyy', 'ru_RU').format(dd);
}

/// Проверяет, попадает ли дата [date] в последние [days] дней от текущего момента.
bool isWithinDays(DateTime date, int days) {
  final now = DateTime.now();
  final from = now.subtract(Duration(days: days));
  return date.isAfter(from) || _sameDay(date, from);
}

/// Сравнивает две даты по календарному дню (без времени).
bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
