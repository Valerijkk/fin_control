// test/ui/screens/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/ui/screens/home_screen.dart';

import '../../helpers/test_host.dart';

void main() {
  testWidgets('Home: summary & filters work', (tester) async {
    final state = TestAppState();
    state.seed([
      exp(title: 'Продукты', amount: 100, category: 'Еда'),
      exp(title: 'Зарплата', amount: 50, category: 'Другое', income: true),
    ]);

    await tester.pumpWidget(makeHost(home: const HomeScreen(), state: state));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('— 50 ₽'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Еда'));
    await tester.pumpAndSettle();
    expect(find.text('Продукты'), findsOneWidget);
    expect(find.text('Зарплата'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Все'));
    await tester.pumpAndSettle();
    expect(find.text('Продукты'), findsOneWidget);
    expect(find.text('Зарплата'), findsOneWidget);
  });

  testWidgets('Home: quick add bottom sheet', (tester) async {
    final state = TestAppState();
    await tester.pumpWidget(makeHost(home: const HomeScreen(), state: state));

    await tester.tap(find.byTooltip('Быстрая запись'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '123');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Добавить'));
    await tester.pumpAndSettle();

    expect(find.text('Быстрое добавление'), findsOneWidget);
    expect(state.items.any((e) => e.title == 'Быстрое добавление' && e.amount == 123), isTrue);
  });

  testWidgets('Home: edit via tile tap', (tester) async {
    final state = TestAppState();
    state.seed([exp(title: 'Такси', amount: 300, category: 'Транспорт')]);

    await tester.pumpWidget(makeHost(home: const HomeScreen(), state: state));

    await tester.tap(find.text('Такси'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), 'Такси (исправлено)');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить изменения'));
    await tester.pumpAndSettle();

    expect(find.text('Такси (исправлено)'), findsOneWidget);
  });

  testWidgets('Home: dismiss delete + UNDO', (tester) async {
    final state = TestAppState();
    state.seed([exp(title: 'Кофе', amount: 200, category: 'Досуг')]);

    await tester.pumpWidget(makeHost(home: const HomeScreen(), state: state));
    expect(find.text('Кофе'), findsOneWidget);

    final d = find.byType(Dismissible).first;
    await tester.drag(d, const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.textContaining('Удалено: Кофе'), findsOneWidget);
    await tester.tap(find.text('ОТМЕНА'));
    await tester.pumpAndSettle();

    expect(find.text('Кофе'), findsOneWidget);
  });
}
