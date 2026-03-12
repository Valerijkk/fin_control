// Глобальная инициализация перед всеми тестами (flutter test).
// Решает: databaseFactory not initialized, Locale data has not been initialized,
// SharedPreferences.getInstance() в тестах на VM.

import 'dart:async';

import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await initializeDateFormatting('ru_RU');
  await initializeDateFormatting();

  SharedPreferences.setMockInitialValues({});

  await testMain();
}
