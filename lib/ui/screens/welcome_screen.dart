import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../widgets/app_bar_title.dart';
import '../widgets/primary_button.dart';
import '../widgets/theme_action.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarTitle(title: 'Добро пожаловать', actions: [ThemeAction()]),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('FinControl', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Калькулятор и учёт расходов', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.shell),
                label: 'Начать',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
