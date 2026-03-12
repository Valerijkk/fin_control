# FinControl — учебная инвестиционная платформа 💸

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Material 3](https://img.shields.io/badge/Material-3-7E57C2?logo=materialdesign&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-local-blue?logo=sqlite&logoColor=white)
![Android](https://img.shields.io/badge/Android-✓-34A853?logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-✓-000000?logo=apple&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-black)

**Учебное приложение для ручных тестировщиков**: одно мобильное (и при необходимости веб) приложение на Flutter — **инвестиционная платформа с актуальными курсами валют, акций, графиками и курсами обмена**. Учёт расходов, обменник, виртуальный портфель. Трафик к API сниффится в **Charles** и **Proxyman**. В **[docs/practices](docs/practices/)** — практики по всем технологиям: Charles, Proxyman, Android Studio, Xcode, ADB, Sentry, AppMetrica, мобильные сборки (TestFlight, Android), Firebase (Crashlytics, FCM, Analytics, Remote Config, Performance, In-App Messaging).


## ✨ Возможности

- 💱 **Курсы обмена**: актуальные курсы валют (RUB/USD/EUR) с публичных API, кэш, офлайн
- 📈 **Инвестиционный портфель**: виртуальный баланс, покупка/продажа валют по курсу, история сделок
- 📊 **Обменник**: калькулятор обмена, история операций (трафик виден в Charles/Proxyman)
- ⚡️ **Учёт расходов/доходов**: запись, категории, фильтры, статистика по категориям
- 🌗 **Тёмная тема** (M3), данные офлайн (SQLite)


## 📋 Тестовая документация

В **[docs/testovaya-dokumentaciya](docs/testovaya-dokumentaciya/)** — детальная документация для тестирования:

- **Фичи** — по каждой фиче: бизнес/функциональные/нефункциональные требования, роли, схема БД, диаграммы состояний ([features](docs/testovaya-dokumentaciya/features/)).
- **Тест-кейсы** — ручные сценарии и таблица автотестов по файлам ([test-cases.md](docs/testovaya-dokumentaciya/test-cases.md)).
- **Практики** — кратко: технология, как используется в проекте, задание ([practices](docs/testovaya-dokumentaciya/practices/)).

**Критерии приёмки** практик для преподавателя: **[docs/kriterii-priemki](docs/kriterii-priemki/)** — чек-листы по каждой практике.


## 📚 Практики для ручных тестеров

Одно и то же приложение FinControl используется во всех практиках (мобильное и при необходимости веб). Индекс: **[docs/practices/README.md](docs/practices/README.md)**.

| № | Практика |
|---|----------|
| 01 | [Charles](docs/practices/01-charles.md) — мобильное и веб-приложение, которое сниффится |
| 02 | [Proxyman](docs/practices/02-proxyman.md) — мобильное и веб-приложение, которое сниффится |
| 03 | [Android Studio](docs/practices/03-android-studio.md) — мобильное приложение: установка в эмуляторе, настройка логирования |
| 04 | [Xcode](docs/practices/04-xcode.md) — мобильное приложение: установка в симуляторе, логирование |
| 05 | [ADB](docs/practices/05-adb.md) — мануал по возможностям ADB на основе этого приложения |
| 06 | [Sentry](docs/practices/06-sentry.md) — мобильное приложение, подключение Sentry SDK |
| 07 | [AppMetrica](docs/practices/07-appmetrica.md) — мобильное приложение, SDK, заведение в AppMetrica, проверка устройств/сессий |
| 08 | [TestFlight](docs/practices/08-testflight.md) — iOS-приложение в TestFlight |
| 09 | [Android-дистрибуция](docs/practices/09-android-distribution.md) — Android-приложение в популярный дистрибьютор |
| 00 | [Firebase](docs/practices/00-firebase-setup.md) — свой проект, подключение приложения (iOS/Android), затем практики: Crashlytics, FCM, Analytics, Remote Config, Performance Monitoring, In-App Messaging |

---

## ⭐ Задание под звёздочкой

В приложении **специально оставлены 5 багов** разной сложности (лёгкие, средние, сложный). Задание: **найти их самостоятельно** — без подсказок, где именно они находятся. Опишите шаги воспроизведения, ожидаемое и фактическое поведение, по возможности укажите экран или сценарий. Задание выполняется по желанию, для зачёта или бонуса — на усмотрение преподавателя.


## 🧭 Структура проекта

```
lib/
├── main.dart
├── config/telemetry.dart       # Sentry, AppMetrica (опционально)
├── core/                       # routes, app_theme, app_router, categories, formatters
├── data/                       # db, category_store
├── domain/models/              # expense, exchange_operation, portfolio_holding, portfolio_transaction
├── domain/repositories/        # expense, exchange, portfolio
├── services/rates_api.dart     # курсы валют (2 провайдера + кэш)
├── state/                      # app_state, app_scope, theme_controller
└── ui/
    ├── screens/                # welcome, shell, home, add_edit, stats, settings, photo_viewer, exchange, portfolio
    └── widgets/                # app_bar_title, primary_button, summary_card, expense_tile, bar_row, rates_card
```

**Архитектура:** UI → state/domain → data; сервисы (HTTP) отдельно; форматирование в `core/formatters.dart`.


## 🚀 Быстрый старт

````bash
git clone https://github.com/Valerijkk/fin_control.git
cd fin_control

flutter pub get
flutter run
````

**Требования**: Flutter **3.x** ✅  •  Dart **3.x** ✅


## 🔌 Платформенные настройки

### Android (`android/app/src/main/AndroidManifest.xml`) 📱

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourname.fincontrol.fin_control">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <!-- для SDK <= 32 -->
    <uses-permission
        android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />

    <application
        android:label="FinControl"
        android:icon="@mipmap/ic_launcher"
        android:enableOnBackInvokedCallback="true">
        <!-- ваши activity/intent-filter здесь -->
    </application>
</manifest>
```


## 🧪 Тесты

Структура:

```
test/
├─ flutter_test_config.dart            # init sqflite_common_ffi для тестов
├─ app_boot_test.dart
├─ helpers/test_host.dart
├─ unit/formatters_test.dart
└─ ui/screens/...
```

`test/flutter_test_config.dart`:

```dart
import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await testMain();
}
```

Запуск:

```bash
flutter test
```


## 💱 Курсы валют: как сделано

* Провайдеры: `exchangerate.host` → fallback `open.er-api.com`
* Таймауты и строгий парсинг JSON
* Кэш последнего успешного ответа (`shared_preferences`), отображаем **офлайн** (есть отметка)


## 🧑‍💻 Сценарии разработчика

```bash
# форматирование
dart format .

# статический анализ
flutter analyze

# сборка релиза Android
flutter build apk --release

# установка apk
flutter install
# или
adb install -r build/app/outputs/flutter-apk/app-release.apk
```


## 🛠️ Траблшутинг

* **`Locale data has not been initialized`** → локаль инициализируется в `main()` через `initializeDateFormatting('ru_RU')` (уже добавлено).
* **`databaseFactory not initialized` в тестах** → проверь `test/flutter_test_config.dart` (см. выше).
* **`dependOnInheritedWidgetOfExactType... before initState`** → читать `AppScope.of(context)` только в `didChangeDependencies()` (исправлено).
* **Курсы «ошибка загрузки»** → покажется кэш с пометкой «офлайн», как только сеть даст ответ — обновится.


## 📦 Основные зависимости

* `sqflite`, `path`
* `http`
* `image_picker`
* `intl`
* `shared_preferences`
* (dev) `sqflite_common_ffi`, `flutter_test`, `flutter_lints`


## 🔮 Roadmap

* 🌍 Локализация ru/en через `intl`/ARB
* 💱 Выбор базовой валюты + исторические графики
* 🧾 Экспорт/импорт (CSV/JSON)
* 🍰 Диаграммы в статистике (`fl_chart`)
* 🧹 Очистка прикреплённых фото при удалении записи
* 🧪 Golden-тесты UI


## 🤝 Контрибьюшн

PR’ы welcome! Соблюдай **flutter\_lints**, **Conventional Commits** и прикладывай хотя бы один тест к новой фиче. 🧪


## 📄 Лицензия

MIT — свободное использование с сохранением копирайта.

---

**FinControl** — учебная инвестиционная платформа для ручных тестеров. Практики по Charles, Proxyman, Android Studio, Xcode, ADB, Sentry, AppMetrica, сборкам и Firebase — в [docs/practices](docs/practices/).