import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:fin_control/core/app_theme.dart';
import 'package:fin_control/state/app_scope.dart';
import 'package:fin_control/state/app_state.dart';
import 'package:fin_control/state/theme_controller.dart';
import 'package:fin_control/core/routes.dart';

import 'package:fin_control/domain/models/expense.dart';

import 'package:fin_control/ui/screens/welcome_screen.dart';
import 'package:fin_control/ui/screens/shell_screen.dart';
import 'package:fin_control/ui/screens/add_edit_screen.dart';
import 'package:fin_control/ui/screens/settings_screen.dart';
import 'package:fin_control/ui/screens/photo_viewer_screen.dart';

final routeObserver = RouteObserver<PageRoute<dynamic>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация локали для Intl (форматирование дат в виджетах)
  try {
    await initializeDateFormatting('ru_RU');
  } catch (_) {
    // ок, используем дефолтную локаль
  }

  runApp(const FinControlRoot());
}

class FinControlRoot extends StatefulWidget {
  const FinControlRoot({super.key});
  @override
  State<FinControlRoot> createState() => _FinControlRootState();
}

class _FinControlRootState extends State<FinControlRoot> {
  final _state = AppState();
  ThemeMode _mode = ThemeMode.light;
  bool _loaded = false;

  void _toggleTheme() =>
      setState(() => _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _state.load();
    if (mounted) setState(() => _loaded = true);
  }

  Route<dynamic> _onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case Routes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen(), settings: s);
      case Routes.shell:
        return MaterialPageRoute(builder: (_) => const ShellScreen(), settings: s);
      case Routes.add:
        final initial = s.arguments is Expense ? s.arguments as Expense? : null;
        return MaterialPageRoute(builder: (_) => AddEditScreen(initial: initial), settings: s);
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen(), settings: s);
      case Routes.photo:
        final path = s.arguments as String;
        return MaterialPageRoute(builder: (_) => PhotoViewerScreen(path: path), settings: s);
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Not found'))),
          settings: s,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinControl',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: AppTheme.buildLight(),
      darkTheme: AppTheme.buildDark(),
      navigatorObservers: [routeObserver],
      onGenerateRoute: _onGenerateRoute,
      initialRoute: Routes.welcome,
      builder: (context, child) {
        if (!_loaded) {
          return Theme(
            data: AppTheme.buildLight(),
            child: const Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return AppScope(
          notifier: _state,
          child: ThemeController(
            mode: _mode,
            toggle: _toggleTheme,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
