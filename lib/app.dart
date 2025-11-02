import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'core/app_router.dart';
import 'core/routes.dart';
import 'state/app_state.dart';
import 'state/app_scope.dart';
import 'state/theme_controller.dart';

class FinControlApp extends StatefulWidget {
  const FinControlApp({super.key});
  @override
  State<FinControlApp> createState() => _FinControlAppState();
}

class _FinControlAppState extends State<FinControlApp> {
  final AppState _state = AppState();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinControl',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: AppTheme.buildLight(),
      darkTheme: AppTheme.buildDark(),
      navigatorObservers: [routeObserver],
      onGenerateRoute: AppRouter.onGenerateRoute,
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
