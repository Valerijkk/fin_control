// Точка входа приложения FinControl. Инициализация телеметрии (Sentry, AppMetrica), локалей, корневой виджет.
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:fin_control/config/telemetry.dart';
import 'package:fin_control/core/app_theme.dart';
import 'package:fin_control/state/app_scope.dart';
import 'package:fin_control/state/app_state.dart';
import 'package:fin_control/state/theme_controller.dart';
import 'package:fin_control/core/app_router.dart';
import 'package:fin_control/core/routes.dart';

/// Инициализация биндингов, AppMetrica (если ключ задан), локалей ru_RU, Sentry (если DSN задан), запуск приложения.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[FinControl] Запуск приложения...');

  if (appMetricaApiKey.isNotEmpty) await _initAppMetrica();
  try {
    await initializeDateFormatting('ru_RU');
  } catch (_) {}

  if (sentryDsn.isNotEmpty) debugPrint('[FinControl] Инициализация Sentry...');
  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 1.0;
        options.environment = 'development';
        options.sendDefaultPii = false;
        options.attachScreenshot = false;
        options.enableAutoNativeBreadcrumbs = true;
      },
      appRunner: () => runApp(const FinControlRoot()),
    );
    // Анонимный пользователь для учебного проекта
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: 'student', username: 'student'));
      scope.setTag('app_type', 'educational');
    });
  } else {
    runApp(const FinControlRoot());
  }
}

/// Активирует AppMetrica с ключом из [appMetricaApiKey].
Future<void> _initAppMetrica() async {
  try {
    await AppMetrica.activate(AppMetricaConfig(appMetricaApiKey));
    debugPrint('[FinControl] AppMetrica инициализирована');
  } catch (_) {}
}

/// Корневой виджет: загрузка данных, тема, маршрутизация, обёртка в [AppScope] и [ThemeController].
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

  /// Загружает расходы и категории из БД; после загрузки [builder] отдаёт [AppScope] и навигацию.
  Future<void> _init() async {
    await _state.load();
    debugPrint('[FinControl] Данные загружены: ${_state.items.length} записей, ${_state.categories.length} категорий');
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinControl',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: AppTheme.buildLight(),
      darkTheme: AppTheme.buildDark(),
      navigatorObservers: [
        routeObserver,
        if (sentryDsn.isNotEmpty) SentryNavigatorObserver(),
      ],
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: Routes.welcome,
      /// Пока загрузка — показываем индикатор; после — оборачиваем в [AppScope] и [ThemeController].
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
