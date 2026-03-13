import 'package:flutter/material.dart';

/// Наблюдатель за сменой маршрутов (для аналитики, восстановления состояния и т.д.).
final routeObserver = RouteObserver<PageRoute<dynamic>>();

/// Имена маршрутов приложения. Используются в [AppRouter] и при навигации.
class Routes {
  /// Экран приветствия (первый запуск).
  static const welcome = '/';
  /// Главный shell с нижней навигацией (Список, Обменник, Акции, Портфель, Статистика).
  static const shell = '/home';
  /// Экран добавления/редактирования расхода или дохода.
  static const add = '/add';
  /// Настройки (тема, тест Sentry и т.д.).
  static const settings = '/settings';
  /// Просмотр фото по пути к файлу (аргумент — String).
  static const photo = '/photo';
  /// Обменник валют.
  static const exchange = '/exchange';
  /// Список акций и покупка в портфель.
  static const stocks = '/stocks';
  /// Портфель: баланс, активы, купить/продать валюту и акции.
  static const portfolio = '/portfolio';
}
