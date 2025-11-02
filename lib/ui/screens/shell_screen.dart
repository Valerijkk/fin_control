import 'package:flutter/material.dart';
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
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Список'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Статистика'),
        ],
      ),
    );
  }
}
