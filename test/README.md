# Тестовый фреймворк FinControl

Полноценная структура тестов: unit, widget, хелперы и конфиг для стабильного запуска на VM (без эмулятора).

## Структура

```
test/
├── flutter_test_config.dart   # Глобальная инициализация: SQLite FFI, intl, SharedPreferences
├── helpers/
│   └── test_host.dart         # TestAppState, makeHost(), exp(), makeTempPng()
├── unit/                      # Юнит-тесты без виджетов
│   ├── formatters_test.dart
│   ├── rates_test.dart
│   └── stocks_api_test.dart
├── ui/screens/                # Виджет-тесты экранов
│   ├── home_screen_test.dart
│   ├── exchange_screen_test.dart
│   ├── portfolio_screen_test.dart
│   ├── stocks_screen_test.dart
│   ├── shell_screen_test.dart
│   ├── add_edit_screen_test.dart
│   ├── settings_screen_test.dart
│   ├── stats_screen_test.dart
│   ├── welcome_screen_test.dart
│   └── photo_viewer_screen_test.dart
└── app_boot_test.dart         # Загрузка приложения (маршруты, конфиг)
```

## Запуск

```bash
# Все тесты
flutter test

# С выводом по каждому тесту
flutter test --reporter expanded

# Только unit
flutter test test/unit/

# Только виджет-тесты экранов
flutter test test/ui/

# Конкретный файл
flutter test test/unit/formatters_test.dart
```

## Инициализация (flutter_test_config.dart)

Перед тестами выполняется:

- `sqfliteFfiInit()` и `databaseFactory = databaseFactoryFfi` — SQLite на VM без платформенного кода
- `initializeDateFormatting('ru_RU')` и `initializeDateFormatting()` — локали для intl
- `SharedPreferences.setMockInitialValues({})` — мок префов

Иначе в тестах возможны: `databaseFactory not initialized`, `Locale data has not been initialized`, падения при обращении к SharedPreferences.

## Хелперы (test_host.dart)

- **TestAppState** — in-memory реализация AppState: `seed()`, `add()`, `removeAt()`, `undoLastRemove()`, `items`.
- **makeHost({ home, state, mode, onToggle })** — обёртка в MaterialApp + AppScope + ThemeController для виджет-тестов.
- **exp({ title, amount, category, income })** — фабрика тестовых расходов/доходов.
- **makeTempPng()** — временный файл с валидным PNG 1×1 (для тестов с фото).

## Unit-тесты

- **formatters_test** — `money()`, `formatDate()`, `shortDayHeader()`, `isWithinDays()`.
- **rates_test** — парсинг и сериализация `Rates` (fromJson/toJson), геттеры `usd`/`eur`/`rate()`.
- **stocks_api_test** — `StocksApi.fetch()` возвращает список акций, `fetchHistory()` — список точек за выбранный период.

## Виджет-тесты

Экраны тестируются через `makeHost()` с `TestAppState`. Проверяется:

- наличие заголовков и ключевых подписей;
- фильтры и быстрая запись (Home);
- свайп удаления и UNDO (Home);
- открытие диалогов (Обменник, Акции, Портфель);
- навигация по вкладкам (Shell).

Экраны с сетевыми запросами (Обменник, Портфель, Акции) при запуске тестов могут показывать загрузку или сообщение об ошибке — тесты проверяют структуру UI и доступность кнопок/полей.

## Добавление нового теста

1. **Unit**: создать файл в `test/unit/`, импорт `package:flutter_test/flutter_test.dart` и тестируемого модуля.
2. **Widget**: импорт `test_host.dart`, `makeHost()` + `TestAppState`, `tester.pumpWidget()`, `find.*`, `expect()`.
3. Для экранов, использующих репозитории/БД: в тестах используется реальный SQLite (FFI) или мок через подмену (если добавите DI).

## CI

В пайплайне достаточно:

```bash
flutter pub get
flutter test
flutter analyze
```
