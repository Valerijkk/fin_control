// test/app_boot_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/app.dart';
import 'package:fin_control/ui/screens/welcome_screen.dart';

void main() {
  testWidgets('FinControlApp boots and shows loading or Welcome', (tester) async {
    await tester.pumpWidget(const FinControlApp());
    await tester.pump();
    // После load() появляется Welcome; пока грузится — CircularProgressIndicator
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(WelcomeScreen).evaluate().isNotEmpty) {
        expect(find.byType(WelcomeScreen), findsOneWidget);
        return;
      }
    }
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
