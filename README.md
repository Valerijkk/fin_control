# FinControl — простой и быстрый учёт расходов 💸

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter\&logoColor=white)]()
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart\&logoColor=white)]()
[![Material 3](https://img.shields.io/badge/Material-3-7E57C2?logo=materialdesign\&logoColor=white)]()
[![SQLite](https://img.shields.io/badge/SQLite-local-blue?logo=sqlite\&logoColor=white)]()
[![Platforms](https://img.shields.io/badge/Android-✓-34A853?logo=android\&logoColor=white)]()
[![License](https://img.shields.io/badge/License-MIT-black)]()

Учебный pet-project на **Flutter** для **молниеносного учёта расходов и доходов**: локальная БД, фото чеков, фильтры, статистика и тёмная тема. 🚀

---

## ✨ Что умеет

* ⚡️ **Быстрая запись** (bottom-sheet: сумма + категория)
* 📝 Полная запись: **сумма, название, категория, доход/расход**, **фото чека** (камера)
* 🧹 Список с **свайп-удалением** и **UNDO** через Snackbar
* 🏷️ **Фильтры по категориям**
* 📊 **Статистика**: суммирование по категориям + итог расходов
* 🌓 **Тёмная тема** (переключатель в настройках)
* 🌐 Виджет курсов (RUB → USD/EUR) с адекватной обработкой ошибки сети
* 💾 Всё **локально** (SQLite через `sqflite`)

---

## 🧭 Структура проекта

```
lib/
├─ main.dart
├─ app.dart
├─ core/
│  ├─ routes.dart            # имена маршрутов
│  ├─ app_router.dart        # onGenerateRoute
│  ├─ app_theme.dart         # светлая/тёмная тема (Material 3)
│  ├─ categories.dart        # константы категорий
│  └─ formatters.dart        # money(), formatDate()
├─ data/
│  └─ db.dart                # SQLite (sqflite)
├─ domain/
│  ├─ models/expense.dart
│  └─ repositories/expense_repository.dart
├─ services/
│  └─ rates_api.dart         # HTTP к exchangerate.host
├─ state/
│  ├─ app_state.dart         # ChangeNotifier (CRUD + undo)
│  ├─ app_scope.dart         # InheritedNotifier
│  └─ theme_controller.dart  # InheritedWidget для темы
└─ ui/
   ├─ screens/               # welcome, shell, home, add_edit, stats, settings, photo_viewer
   └─ widgets/               # app_bar_title, theme_action, primary_button, summary_card, expense_tile, bar_row, rates_card
```

> Почему так? 🧩
>
> * **UI без бизнес-логики**
> * **State** знает про репозиторий, а не про `sqflite` → легче тестировать и менять хранилище
> * **Services** отдельно от данных/БД
> * Переиспользуемые куски — в `ui/widgets`
> * Форматирование денег/дат централизовано в `core/formatters.dart`

---

---

## 🚀 Быстрый старт

```bash
# 1) Клонируем
git clone https://github.com/Valerijkk/fin_control.git
cd fin_control

# 2) Зависимости
flutter pub get

# 3) Запуск
flutter run
```

**Требования**: Flutter **3.x**, Dart **3.x** ✅

---

## 🔌 Платформенные настройки

### Android (`AndroidManifest.xml`) 📱

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
```

### iOS (`Info.plist`) 🍏

```xml
<key>NSCameraUsageDescription</key>
<string>Нужно для прикрепления фото чека к записи расходов</string>
```

---

## 🧪 Тесты (модульные + виджетные)

Структура тестов читается с первого взгляда:

```
test/
├─ helpers/test_host.dart                 # TestAppState, сборка хоста, утилиты
├─ unit/formatters_test.dart              # money(), formatDate()
├─ ui/screens/
│  ├─ welcome_screen_test.dart
│  ├─ home_screen_test.dart              # quick-add, фильтры, удаление+UNDO, редактирование
│  ├─ add_edit_screen_test.dart
│  ├─ stats_screen_test.dart
│  ├─ settings_screen_test.dart          # toggle темы
│  ├─ photo_viewer_screen_test.dart
│  └─ shell_screen_test.dart
└─ app_boot_test.dart                    # приложение грузится в Welcome
```

Запуск:

```bash
flutter test
```

---

## 📦 Основные зависимости

* `sqflite` — SQLite на устройстве
* `path` — для путей БД
* `http` — курсы валют
* `image_picker` — фото чеков
* `intl` — форматирование чисел и дат
* (из Flutter SDK) `material`, `services`

---

## 🧑‍💻 Скрипты разработчика

```bash
# форматирование кода
dart format .

# статический анализ
flutter analyze

# сборка релиза Android
flutter build apk --release
```

---

## 🔮 Roadmap

* 🌍 Локализация (ru/en) через `intl`
* 💱 Кэш/выбор валюты, исторические графики
* 🧾 Экспорт/импорт (CSV/JSON)
* 🍰 Диаграммы в статистике (`fl_chart`)
* 🧹 Очистка прикреплённых фото при удалении записи (ImageRepository)
* 🧪 Golden-тесты UI

---

## 🤝 Как контрибьютить

PR’ы welcome! Правила коротко:

* стиль кода — стандарт Flutter/Dart (см. `flutter_lints`)
* коммиты — **Conventional Commits** (`feat:`, `fix:`, `refactor:`…)
* на новую фичу — минимум один тест 🧪

---

## 📄 Лицензия

MIT — делай, что хочешь, но сохраняй копирайт. ♥

---

## 🙌 Спасибо

За интерес к аккуратному Flutter-коду, минимализму и прозрачной архитектуре. Если проект помог — ⭐ звезда в репозитории и идеи в issues.
**Good vibes only!** ✨
