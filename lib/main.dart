import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:fin_control/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting();
    await initializeDateFormatting('ru');
    await initializeDateFormatting('ru_RU');
  } catch (_) {}
  runApp(const FinControlApp());
}
