// test/unit/formatters_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/core/formatters.dart';

void main() {
  test('money()', () {
    expect(money(0), '0 ₽');
    expect(money(12.34), '12 ₽');
  });

  test('formatDate()', () {
    final d = DateTime(2025, 1, 2, 3, 4);
    expect(formatDate(d), '02.01.2025 • 03:04');
  });
}
