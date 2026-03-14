// test/ui/screens/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/ui/screens/add_edit_screen.dart';
import 'package:fin_control/ui/screens/home_screen.dart';

import '../../helpers/test_host.dart';

void main() {
  testWidgets('Home: отображает итог и фильтрацию по категориям', (tester) async {
    final state = TestAppState();
    state.seed([
      exp(title: 'Продукты', amount: 100, category: 'Еда'),
      exp(title: 'Зарплата', amount: 50, category: 'Другое', income: true),
    ]);

    await tester.pumpWidget(makeHost(home: const HomeScreen(), state: state));
    await tester.pumpAndSettle();

    expect(find.textContaining('— 50 ₽'), findsOneWidget);

    await tester.ensureVisible(find.text('Еда'));
    await tester.tap(find.text('Еда'));
    await tester.pumpAndSettle();
    expect(find.text('Продукты'), findsOneWidget);
    expect(find.text('Зарплата'), findsNothing);

    await tester.ensureVisible(find.text('Все категории'));
    await tester.tap(find.text('Все категории'));
    await tester.pumpAndSettle();
    // Прокрутка списка, чтобы лениво построилась вторая запись (Зарплата)
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(find.text('Продукты'), findsOneWidget);
    expect(find.text('Зарплата'), findsOneWidget);
  });

  testWidgets('Home: quick add bottom sheet', (tester) async {
    final state = TestAppState();
    await tester.pumpWidget(makeHost(home: const HomeScreen(), state: state));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Быстрая запись'));
    await tester.pumpAndSettle();
    expect(find.text('Быстрая запись'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '123');
    await tester.pump();

    await tester.tap(find.text('Добавить'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Быстрая запись'), findsNothing,
        reason: 'После нажатия «Добавить» bottom sheet должен закрыться');
  });

  testWidgets('Home: редактирование по тапу на запись', (tester) async {
    final state = TestAppState();
    state.seed([exp(title: 'Такси', amount: 300, category: 'Транспорт')]);

    await tester.pumpWidget(makeHost(home: const HomeScreen(), state: state));
    await tester.pumpAndSettle();
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -200));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Такси'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextFormField).at(1), 'Такси (исправлено)');
    await tester.pump();

    await tester.tap(find.text('Сохранить изменения'));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(AddEditScreen).evaluate().isEmpty) break;
    }
    expect(find.byType(AddEditScreen), findsNothing);
    expect(find.text('Такси (исправлено)'), findsAtLeastNWidgets(1));
    // Дожидаемся завершения таймера SavingsGoalCard (10 с), чтобы не оставалось pending timers после dispose.
    await tester.pumpAndSettle(const Duration(seconds: 11));
  });

  testWidgets('Home: свайп удаление и отмена (UNDO)', (tester) async {
    final state = TestAppState();
    state.seed([exp(title: 'Кофе', amount: 200, category: 'Досуг')]);

    await tester.pumpWidget(makeHost(home: const HomeScreen(), state: state));
    await tester.pumpAndSettle();
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(find.text('Кофе'), findsOneWidget);

    final d = find.byType(Dismissible).first;
    await tester.ensureVisible(d);
    await tester.drag(d, const Offset(-500, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.textContaining('Удалено: Кофе'), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();

    expect(find.text('Кофе'), findsOneWidget);
  });
}
