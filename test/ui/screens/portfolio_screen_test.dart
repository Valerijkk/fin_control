// test/ui/screens/portfolio_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/ui/screens/portfolio_screen.dart';

import '../../helpers/test_host.dart';

void main() {
  testWidgets('Portfolio: заголовок Портфель', (tester) async {
    final state = TestAppState();
    await tester.pumpWidget(makeHost(home: const PortfolioScreen(), state: state));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Портфель'), findsOneWidget);
  });

  testWidgets('Portfolio: секция Активы', (tester) async {
    final state = TestAppState();
    await tester.pumpWidget(makeHost(home: const PortfolioScreen(), state: state));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('Активы'), findsOneWidget);
  });
}
