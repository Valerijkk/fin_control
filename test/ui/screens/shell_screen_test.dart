// test/ui/screens/shell_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/ui/screens/shell_screen.dart';
import 'package:fin_control/ui/screens/stats_screen.dart';

import '../../helpers/test_host.dart';

void main() {
  testWidgets('Shell: bottom navigation switches to Stats', (tester) async {
    final state = TestAppState();
    await tester.pumpWidget(makeHost(home: const ShellScreen(), state: state));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Статистика'));
    await tester.pumpAndSettle();

    expect(find.byType(StatsScreen), findsOneWidget);
  });
}
