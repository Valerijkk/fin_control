// test/ui/screens/stats_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/ui/screens/shell_screen.dart';
import 'package:fin_control/ui/screens/stats_screen.dart';

import '../../helpers/test_host.dart';

void main() {
  testWidgets('Stats: aggregated total is shown', (tester) async {
    final state = TestAppState();
    state.seed([
      exp(title: 'Еда', amount: 100, category: 'Еда'),
      exp(title: 'Доход', amount: 30, category: 'Другое', income: true),
      exp(title: 'Дом', amount: 20, category: 'Дом'),
    ]); // расходы 120, доход 30 => "Всего расходов: 120 ₽"

    await tester.pumpWidget(makeHost(home: const ShellScreen(), state: state));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Статистика'));
    await tester.pumpAndSettle();

    expect(find.byType(StatsScreen), findsOneWidget);
    expect(find.textContaining('Всего расходов: 120 ₽'), findsOneWidget);
  });
}
