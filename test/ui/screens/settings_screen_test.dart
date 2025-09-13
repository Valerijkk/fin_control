// test/ui/screens/settings_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/ui/screens/settings_screen.dart';
import 'package:fin_control/state/app_scope.dart';
import 'package:fin_control/state/theme_controller.dart';

import '../../helpers/test_host.dart';

void main() {
  testWidgets('Settings: toggles theme (toggle() called)', (tester) async {
    final state = TestAppState();
    var toggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          notifier: state,
          child: ThemeController(
            mode: ThemeMode.light,
            toggle: () => toggled = true,
            child: const SettingsScreen(),
          ),
        ),
      ),
    );

    expect(toggled, isFalse);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(toggled, isTrue);
  });
}
