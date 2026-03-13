// Главный экран с нижней навигацией: Список, Обменник, Акции, Портфель, Статистика.
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'exchange_screen.dart';
import 'portfolio_screen.dart';
import 'stocks_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});
  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const ExchangeScreen(),
      const StocksScreen(),
      const PortfolioScreen(),
      const StatsScreen(),
    ];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Список'),
          NavigationDestination(icon: Icon(Icons.currency_exchange), label: 'Обменник'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Акции'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Портфель'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Статистика'),
        ],
      ),
    );
  }
}
