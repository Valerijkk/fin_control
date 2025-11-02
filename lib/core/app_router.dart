import 'package:flutter/material.dart';
import '../core/routes.dart';
import '../ui/screens/welcome_screen.dart';
import '../ui/screens/shell_screen.dart';
import '../ui/screens/add_edit_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/screens/photo_viewer_screen.dart';
import '../domain/models/expense.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings s) {
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
}
