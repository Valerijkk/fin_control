// test/app_boot_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/app.dart';
import 'package:fin_control/ui/screens/welcome_screen.dart';

void main() {
  testWidgets('FinControlApp boots to Welcome', (tester) async {
    await tester.pumpWidget(const FinControlApp());
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
