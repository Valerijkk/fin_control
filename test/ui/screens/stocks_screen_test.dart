// test/ui/screens/stocks_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/ui/screens/stocks_screen.dart';

import '../../helpers/test_host.dart';

void main() {
  testWidgets('Stocks: заголовок и вкладка Акции', (tester) async {
    final state = TestAppState();
    await tester.pumpWidget(makeHost(home: const StocksScreen(), state: state));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Акции и криптовалюта'), findsOneWidget);
    expect(find.text('Акции'), findsOneWidget);
    expect(find.text('Криптовалюта'), findsOneWidget);
  });

  testWidgets('Stocks: после загрузки список акций или индикатор', (tester) async {
    final state = TestAppState();
    await tester.pumpWidget(makeHost(home: const StocksScreen(), state: state));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final hasProgress = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    final hasList = find.textContaining('AAPL').evaluate().isNotEmpty ||
        find.textContaining('MSFT').evaluate().isNotEmpty;
    expect(hasProgress || hasList, isTrue);
  });

  testWidgets('Stocks: чипы периодов графика', (tester) async {
    final state = TestAppState();
    await tester.pumpWidget(makeHost(home: const StocksScreen(), state: state));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('1Д'), findsOneWidget);
    expect(find.text('1Н'), findsOneWidget);
  });
}
