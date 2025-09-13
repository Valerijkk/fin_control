// test/ui/screens/welcome_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/ui/screens/welcome_screen.dart';

import '../../helpers/test_host.dart';

void main() {
  testWidgets('Welcome renders and navigates to Shell', (tester) async {
    final state = TestAppState();
    await tester.pumpWidget(makeHost(home: const WelcomeScreen(), state: state));

    expect(find.text('FinControl'), findsOneWidget);
    expect(find.text('Калькулятор и учёт расходов'), findsOneWidget);

    await tester.tap(find.text('Начать'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
