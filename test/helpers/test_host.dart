// test/helpers/test_host.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fin_control/core/app_router.dart';
import 'package:fin_control/state/app_scope.dart';
import 'package:fin_control/state/app_state.dart';
import 'package:fin_control/state/theme_controller.dart';
import 'package:fin_control/domain/models/expense.dart';

class TestAppState extends AppState {
  final List<Expense> _list = [];
  Expense? _lastRemoved;
  int? _lastIndex;

  @override
  List<Expense> get items => List.unmodifiable(_list);

  @override
  Future<void> load() async {}

  @override
  Future<void> add(Expense e) async {
    _list.insert(0, e);
    notifyListeners();
  }

  @override
  Future<void> update(String id, Expense e) async {
    final i = _list.indexWhere((x) => x.id == id);
    if (i == -1) return;
    _list[i] = e;
    notifyListeners();
  }

  @override
  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _list.length) return;
    _lastRemoved = _list.removeAt(index);
    _lastIndex = index;
    notifyListeners();
  }

  @override
  Future<bool> undoLastRemove() async {
    if (_lastRemoved == null || _lastIndex == null) return false;
    final i = (_lastIndex!).clamp(0, _list.length);
    _list.insert(i, _lastRemoved!);
    _lastRemoved = null;
    _lastIndex = null;
    notifyListeners();
    return true;
  }

  void seed(List<Expense> data) {
    _list
      ..clear()
      ..addAll(data);
    notifyListeners();
  }
}

Widget makeHost({
  required Widget home,
  required TestAppState state,
  ThemeMode mode = ThemeMode.light,
  VoidCallback? onToggle,
}) {
  return MaterialApp(
    onGenerateRoute: AppRouter.onGenerateRoute,
    home: home,
    builder: (context, child) => AppScope(
      notifier: state,
      child: ThemeController(
        mode: mode,
        toggle: onToggle ?? () {},
        child: child ?? const SizedBox.shrink(),
      ),
    ),
  );
}

/// Валидный PNG 1x1 для тестов
Future<File> makeTempPng() async {
  const base64Png =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=';
  final bytes = base64.decode(base64Png);
  final file = File('${Directory.systemTemp.path}/fc_test_${DateTime.now().microsecondsSinceEpoch}.png');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

Expense exp({
  required String title,
  required double amount,
  String category = 'Еда',
  bool income = false,
}) =>
    Expense(
      id: 'e_${title}_${amount}_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      amount: amount,
      category: category,
      date: DateTime(2025, 1, 2, 3, 4),
      isIncome: income,
    );
