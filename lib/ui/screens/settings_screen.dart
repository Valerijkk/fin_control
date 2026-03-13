// Настройки: тёмная тема, очистка данных, кнопка «Тест Sentry».
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../config/telemetry.dart';
import '../../state/theme_controller.dart';
import '../../state/app_scope.dart';
import '../widgets/app_bar_title.dart';
import '../widgets/theme_action.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = ThemeController.of(context);
    final isDark = ctrl.mode == ThemeMode.dark;
    final state = AppScope.of(context);

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
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Очистить все данные'),
            subtitle: const Text('Удаляет все записи расходов/доходов из локальной БД'),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Подтвердите'),
                  content: const Text('Удалить все записи безвозвратно?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
                  ],
                ),
              ) ??
                  false;
              if (ok) {
                await state.clearAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Данные очищены')),
                  );
                }
              }
            },
          ),
          if (sentryDsn.isNotEmpty) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('Тест Sentry'),
              subtitle: const Text('Отправить тестовое исключение в Sentry'),
              onTap: () {
                Sentry.captureException(Exception('Тестовое исключение из FinControl (Настройки)'));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Исключение отправлено в Sentry')),
                  );
                }
              },
            ),
          ],
          const Divider(),
          const ListTile(
            title: Text('О приложении'),
            subtitle: Text('FinControl — учебная платформа: учёт расходов, обменник, портфель.'),
          ),
        ],
      ),
    );
  }
}
