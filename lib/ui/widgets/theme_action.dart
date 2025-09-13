import 'package:flutter/material.dart';
import '../../../state/theme_controller.dart';

class ThemeAction extends StatelessWidget {
  const ThemeAction({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = ThemeController.of(context);
    final isDark = ctrl.mode == ThemeMode.dark;
    return IconButton(
      tooltip: 'Переключить тему',
      onPressed: ctrl.toggle,
      icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined),
    );
  }
}
