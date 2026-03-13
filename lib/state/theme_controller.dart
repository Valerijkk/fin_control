import 'package:flutter/material.dart';

/// [InheritedWidget] для текущей темы (светлая/тёмная) и переключателя.
/// Потомки получают: [ThemeController.of(context).mode] и [ThemeController.of(context).toggle].
class ThemeController extends InheritedWidget {
  /// Текущий режим темы (light/dark/system).
  final ThemeMode mode;
  /// Колбэк переключения темы (вызывается из кнопки в AppBar).
  final VoidCallback toggle;

  const ThemeController({super.key, required this.mode, required this.toggle, required super.child});

  /// Получить [ThemeController] из контекста.
  static ThemeController of(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<ThemeController>()!;

  @override
  bool updateShouldNotify(covariant ThemeController old) => old.mode != mode;
}
