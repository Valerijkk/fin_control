import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import 'home_screen.dart';
import 'stats_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});
  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [const HomeScreen(), const StatsScreen()];
    final l10n = context.l10n;

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.list_alt), label: l10n.shellListTab),
          NavigationDestination(icon: const Icon(Icons.insights), label: l10n.shellStatsTab),
        ],
      ),
    );
  }
}
