// test/ui/screens/add_edit_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/ui/screens/add_edit_screen.dart';
import 'package:fin_control/domain/models/expense.dart';

import '../../helpers/test_host.dart';

void main() {
  testWidgets('AddEdit: create new expense and pop', (tester) async {
    final state = TestAppState();

    await tester.pumpWidget(makeHost(home: const AddEditScreen(), state: state));
    await tester.enterText(find.byType(TextFormField).at(0), '200');
    await tester.enterText(find.byType(TextFormField).at(1), 'Продукты');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить'));
    await tester.pumpAndSettle();

    // Вернулись назад — просто smoke (нет явной проверки state, т.к. экран сам pop-ает результат)
    expect(find.byType(AddEditScreen), findsNothing);
  });

  testWidgets('AddEdit: edit initial shows button "Сохранить изменения"', (tester) async {
    final init = Expense(
      id: 'e1',
      title: 'Такси',
      amount: 300,
      category: 'Транспорт',
      date: DateTime(2025, 1, 1),
    );

    final state = TestAppState();
    await tester.pumpWidget(makeHost(home: AddEditScreen(initial: init), state: state));

    expect(find.widgetWithText(FilledButton, 'Сохранить изменения'), findsOneWidget);
  });
}
