import 'package:flutter/widgets.dart';
import 'app_state.dart';

/// [InheritedWidget], который предоставляет [AppState] всем потомкам.
/// Используется так: `AppScope.of(context)` — возвращает текущий [AppState].
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState notifier, required super.child})
      : super(notifier: notifier);

  /// Получить [AppState] из контекста. Вызывать только после [AppScope] в дереве (например в [ShellScreen] и ниже).
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
