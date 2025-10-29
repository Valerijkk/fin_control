import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _themePrefKey = 'app_theme_mode';
  final AppState _state = AppState();
  ThemeMode _mode = ThemeMode.light;
  bool _loaded = false;

  void _toggleTheme() {
    final next = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setState(() => _mode = next);
    unawaited(_persistTheme(next));
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.wait([_loadTheme(), _state.load()]);
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themePrefKey);
    if (stored == null) return;
    final savedMode =
        ThemeMode.values.firstWhere((m) => m.name == stored, orElse: () => _mode);
    _mode = savedMode;
  }

  Future<void> _persistTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefKey, mode.name);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'FinControl',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: AppTheme.buildLight(),
      darkTheme: AppTheme.buildDark(),
      navigatorObservers: [routeObserver],
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: Routes.welcome,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final locale = Localizations.localeOf(context);
        final localeName =
            locale.countryCode != null && locale.countryCode!.isNotEmpty
                ? '${locale.languageCode}_${locale.countryCode}'
                : locale.languageCode;
        Intl.defaultLocale = localeName;
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
