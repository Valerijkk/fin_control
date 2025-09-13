import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData _base({required Brightness brightness}) {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF6750A4),
      brightness: brightness,
    );
    final onBg = brightness == Brightness.dark ? Colors.white : const Color(0xFF1D1B20);
    final hint = brightness == Brightness.dark ? Colors.white70 : const Color(0xFF49454F);

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onBg),
        titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onBg),
        bodyLarge: TextStyle(fontSize: 16, color: onBg),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark ? const Color(0xFF1F1B24) : const Color(0xFFF7F2FA),
        labelStyle: TextStyle(color: onBg),
        hintStyle: TextStyle(color: hint),
        border: const OutlineInputBorder(),
      ),
      chipTheme: base.chipTheme.copyWith(
        labelStyle: TextStyle(color: onBg),
      ),
    );
  }

  static ThemeData buildLight() => _base(brightness: Brightness.light);
  static ThemeData buildDark() => _base(brightness: Brightness.dark);
}
