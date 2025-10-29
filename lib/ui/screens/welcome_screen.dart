import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../widgets/app_bar_title.dart';
import '../widgets/primary_button.dart';
import '../widgets/theme_action.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBarTitle(title: l10n.welcomeTitle, actions: const [ThemeAction()]),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.appTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(l10n.welcomeSubtitle, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.shell),
                label: l10n.welcomeStartButton,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
