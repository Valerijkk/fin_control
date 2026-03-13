// test/unit/app_state_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/domain/models/expense.dart';
import 'package:fin_control/state/app_state.dart';

void main() {
  late AppState state;

  setUp(() async {
    state = AppState();
    await state.load();
    await state.clearAll();
  });

  group('AppState', () {
    test('load инициализирует пустой список', () async {
      await state.load();
      expect(state.items, isEmpty);
      expect(state.categories, isNotEmpty);
    });

    test('add добавляет запись в начало', () async {
      await state.load();
      final e = Expense(
        id: 'ast-1',
        title: 'Расход',
        amount: 200,
        category: 'Еда',
        date: DateTime(2025, 3, 10),
        isIncome: false,
      );
      await state.add(e);
      expect(state.items.length, 1);
      expect(state.items.first.id, 'ast-1');
      expect(state.items.first.amount, 200);
    });

    test('removeAt удаляет запись и сохраняет для undo', () async {
      await state.load();
      final e = Expense(
        id: 'ast-undo',
        title: 'На удаление',
        amount: 1,
        category: 'Другое',
        date: DateTime.now(),
        isIncome: false,
      );
      await state.add(e);
      expect(state.items.length, 1);
      await state.removeAt(0);
      expect(state.items, isEmpty);
      final undone = await state.undoLastRemove();
      expect(undone, isTrue);
      expect(state.items.length, 1);
      expect(state.items.first.id, 'ast-undo');
    });

    test('undoLastRemove без удаления возвращает false', () async {
      await state.load();
      final result = await state.undoLastRemove();
      expect(result, isFalse);
    });

    test('clearAll очищает список', () async {
      await state.load();
      await state.add(Expense(
        id: 'ast-c',
        title: 'Чистка',
        amount: 1,
        category: 'Другое',
        date: DateTime.now(),
        isIncome: false,
      ));
      expect(state.items.length, 1);
      await state.clearAll();
      expect(state.items, isEmpty);
    });

    test('addCategory добавляет новую категорию', () async {
      await state.load();
      final initialCount = state.categories.length;
      final added = await state.addCategory('НоваяКатегория');
      expect(added, 'НоваяКатегория');
      expect(state.categories.length, initialCount + 1);
      expect(state.categories.contains('НоваяКатегория'), isTrue);
    });

    test('addCategory с пустым именем возвращает null', () async {
      await state.load();
      expect(await state.addCategory(''), isNull);
      expect(await state.addCategory('   '), isNull);
    });
  });
}
