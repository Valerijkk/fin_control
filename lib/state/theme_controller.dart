import 'package:flutter/material.dart';

class ThemeController extends InheritedWidget {
  final ThemeMode mode;
  final VoidCallback toggle;
  const ThemeController({super.key, required this.mode, required this.toggle, required super.child});

  static ThemeController of(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<ThemeController>()!;

  @override
  bool updateShouldNotify(covariant ThemeController old) => old.mode != mode;
}
