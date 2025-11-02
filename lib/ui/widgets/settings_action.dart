import 'package:flutter/material.dart';
import '../../../core/routes.dart';

class SettingsAction extends StatelessWidget {
  const SettingsAction({super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Настройки',
      onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
      icon: const Icon(Icons.settings_outlined),
    );
  }
}
