import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:fin_control/config/telemetry.dart';
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
import 'package:fin_control/ui/screens/exchange_screen.dart';
import 'package:fin_control/ui/screens/stocks_screen.dart';
import 'package:fin_control/ui/screens/portfolio_screen.dart';

final routeObserver = RouteObserver<PageRoute<dynamic>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (appMetricaApiKey.isNotEmpty) await _initAppMetrica();
  try {
    await initializeDateFormatting('ru_RU');
  } catch (_) {}

  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 1.0;
        options.environment = 'development';
      },
      appRunner: () => runApp(const FinControlRoot()),
    );
  } else {
    runApp(const FinControlRoot());
  }
}

Future<void> _initAppMetrica() async {
  try {
    await AppMetrica.activate(AppMetricaConfig(appMetricaApiKey));
  } catch (_) {}
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
      case Routes.exchange:
        return MaterialPageRoute(builder: (_) => const ExchangeScreen(), settings: s);
      case Routes.stocks:
        return MaterialPageRoute(builder: (_) => const StocksScreen(), settings: s);
      case Routes.portfolio:
        return MaterialPageRoute(builder: (_) => const PortfolioScreen(), settings: s);
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
