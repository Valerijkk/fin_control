import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const FinControlRoot());
    await tester.pump();
    expect(find.byType(FinControlRoot), findsOneWidget);
  });
}
