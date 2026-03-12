// test/ui/screens/shell_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/ui/screens/shell_screen.dart';
import 'package:fin_control/ui/screens/stats_screen.dart';

import '../../helpers/test_host.dart';

void main() {
  testWidgets('Shell: bottom navigation switches to Stats', (tester) async {
    final state = TestAppState();
    await tester.pumpWidget(makeHost(home: const ShellScreen(), state: state));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Статистика'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(StatsScreen), findsOneWidget);
  });
}
