// Подзаголовок секции (например «История обменов», «Активы») в стиле темы.
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

/// Заголовок секции в стиле темы (жирный, цвет primary).
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppTheme.screenPadding),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
