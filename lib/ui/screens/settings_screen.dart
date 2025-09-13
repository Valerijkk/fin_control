import 'package:flutter/material.dart';
import '../../state/theme_controller.dart';
import '../widgets/app_bar_title.dart';
import '../widgets/theme_action.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = ThemeController.of(context);
    final isDark = ctrl.mode == ThemeMode.dark;
    return Scaffold(
      appBar: const AppBarTitle(title: 'Настройки', canPop: true, actions: [ThemeAction()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: isDark,
            onChanged: (_) => ctrl.toggle(),
            title: const Text('Тёмная тема'),
            subtitle: const Text('Переключить оформление приложения'),
          ),
          const Divider(),
          const ListTile(
            title: Text('О приложении'),
            subtitle: Text('FinControl — учебный прототип учёта расходов.'),
          ),
        ],
      ),
    );
  }
}
