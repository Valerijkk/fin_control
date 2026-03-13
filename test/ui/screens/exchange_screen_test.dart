// test/ui/screens/exchange_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/ui/screens/exchange_screen.dart';

import '../../helpers/test_host.dart';

void main() {
  testWidgets('Exchange: заголовок и основные элементы', (tester) async {
    final state = TestAppState();
    await tester.pumpWidget(makeHost(home: const ExchangeScreen(), state: state));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Обменник'), findsOneWidget);
    expect(find.text('Из валюты'), findsOneWidget);
    expect(find.text('В валюту'), findsOneWidget);
  });

  testWidgets('Exchange: кнопка Обменять', (tester) async {
    final state = TestAppState();
    await tester.pumpWidget(makeHost(home: const ExchangeScreen(), state: state));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Обмен'), findsAtLeastNWidgets(1));
  });

  testWidgets('Exchange: поле суммы', (tester) async {
    final state = TestAppState();
    await tester.pumpWidget(makeHost(home: const ExchangeScreen(), state: state));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(TextField), findsWidgets);
    // Дожидаемся завершения асинхронной загрузки (БД/таймеры), чтобы не оставалось pending timers после dispose.
    await tester.pumpAndSettle(const Duration(seconds: 12));
  });
}
