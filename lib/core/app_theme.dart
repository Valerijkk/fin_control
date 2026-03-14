import 'package:flutter/material.dart';

/// Тема приложения (Material 3): светлая и тёмная. Задаёт цвета, карточки, поля ввода, типографику.
/// Константы отступов используются в экранах и виджетах для единообразия.
class AppTheme {
  /// Горизонтальный отступ экрана от краёв (padding контента).
  static const double screenPadding = 16;
  /// Вертикальный отступ между блоками (мелкий).
  static const double sectionSpacing = 8;
  /// Вертикальный отступ между крупными секциями.
  static const double sectionSpacingLarge = 24;
  /// Внутренний отступ контента внутри карточки (Card child padding).
  static const double cardContentPadding = 16;

  /// Базовая тема с [brightness]. Общие настройки для светлой и тёмной версий.
  static ThemeData _base({required Brightness brightness}) {
    final seed = const Color(0xFF6750A4);
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );

    final onBg = brightness == Brightness.dark ? Colors.white : const Color(0xFF1D1B20);
    final hint = brightness == Brightness.dark ? Colors.white70 : const Color(0xFF49454F);

    return base.copyWith(
      visualDensity: VisualDensity.adaptivePlatformDensity,

      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: scheme.surfaceContainerHighest,
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
      ),

      chipTheme: base.chipTheme.copyWith(
        labelStyle: TextStyle(color: onBg),
        shape: StadiumBorder(side: BorderSide(color: scheme.outlineVariant)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        labelStyle: TextStyle(color: onBg),
        hintStyle: TextStyle(color: hint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary),
        ),
      ),

      textTheme: base.textTheme.copyWith(
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onBg),
        titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onBg),
        bodyLarge: TextStyle(fontSize: 16, color: onBg),
        bodyMedium: TextStyle(fontSize: 14, color: onBg.withValues(alpha: 0.9)),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: onBg,
        centerTitle: true,
      ),

      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    );
  }

  /// Светлая тема.
  static ThemeData buildLight() => _base(brightness: Brightness.light);
  /// Тёмная тема.
  static ThemeData buildDark() => _base(brightness: Brightness.dark);
}
