import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../state/app_scope.dart';
import '../../state/theme_controller.dart';
import '../widgets/app_bar_title.dart';
import '../widgets/theme_action.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = ThemeController.of(context);
    final isDark = ctrl.mode == ThemeMode.dark;
    final state = AppScope.of(context);

    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBarTitle(title: l10n.settingsTitle, canPop: true, actions: const [ThemeAction()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: isDark,
            onChanged: (_) => ctrl.toggle(),
            title: Text(l10n.settingsDarkThemeTitle),
            subtitle: Text(l10n.settingsDarkThemeSubtitle),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: Text(l10n.settingsClearTitle),
            subtitle: Text(l10n.settingsClearSubtitle),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(l10n.settingsConfirmTitle),
                  content: Text(l10n.settingsConfirmMessage),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonDelete)),
                  ],
                ),
              ) ??
                  false;
              if (ok) {
                await state.clearAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.settingsClearedMessage)),
                  );
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.settingsAboutTitle),
            subtitle: Text(l10n.settingsAboutDescription),
          ),
        ],
      ),
    );
  }
}
