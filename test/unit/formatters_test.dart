// test/unit/formatters_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/core/formatters.dart';

void main() {
  group('money', () {
    test('форматирует рубли', () {
      expect(money(0), '0 ₽');
      expect(money(12.34), '12 ₽');
      expect(money(1000000), isNotEmpty);
      expect(money(1000000), endsWith(' ₽'));
    });
  });

  group('formatDate', () {
    test('дата и время с ведущими нулями', () {
      final d = DateTime(2025, 1, 2, 3, 4);
      expect(formatDate(d), '02.01.2025 • 03:04');
    });
  });

  group('shortDayHeader', () {
    test('сегодня', () {
      final now = DateTime.now();
      expect(shortDayHeader(now), 'Сегодня');
    });
    test('вчера', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      expect(shortDayHeader(yesterday), 'Вчера');
    });
    test('старая дата — полный формат с годом', () {
      expect(shortDayHeader(DateTime(2019, 6, 15)), contains('2019'));
    });
  });

  group('isWithinDays', () {
    test('сегодня входит в 7 дней', () {
      expect(isWithinDays(DateTime.now(), 7), isTrue);
    });
    test('дата 10 дней назад не входит в 7', () {
      final old = DateTime.now().subtract(const Duration(days: 10));
      expect(isWithinDays(old, 7), isFalse);
    });
  });
}
