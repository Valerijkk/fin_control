# FinControl — учебная инвестиционная платформа 💸

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Material 3](https://img.shields.io/badge/Material-3-7E57C2?logo=materialdesign&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-local-blue?logo=sqlite&logoColor=white)
![Android](https://img.shields.io/badge/Android-✓-34A853?logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-✓-000000?logo=apple&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-black)

**Учебное приложение на Flutter** — инвестиционная платформа с курсами валют, акций и обменником. Учёт расходов, виртуальный портфель, трафик к API перехватывается в **Charles** и **Proxyman**. Всё настроено **из коробки**; метрики и Firebase — только подставить **токены в указанный файл** [lib/config/student_env.dart](lib/config/student_env.dart) (и конфиги Firebase по инструкциям). Практики по технологиям — в **[docs/practices](docs/practices/)**: Charles, Proxyman, Android Studio, Xcode, ADB, Sentry, AppMetrica, TestFlight, Android-дистрибуция, Firebase (настройка + Crashlytics, FCM, Analytics, Remote Config, Performance, In-App Messaging).


## ✨ Возможности

- 💱 **Курсы обмена**: актуальные курсы валют (RUB/USD/EUR) с публичных API, кэш, офлайн
- 📈 **Инвестиционный портфель**: виртуальный баланс, покупка/продажа валют по курсу, история сделок
- 📊 **Обменник**: калькулятор обмена, история операций (трафик виден в Charles/Proxyman)
- ⚡️ **Учёт расходов/доходов**: запись, категории, фильтры, статистика по категориям
- 🌗 **Тёмная тема** (M3), данные офлайн (SQLite)


## 📋 Документация по практикам

- **Пошаговые инструкции** (клонирование, Android Studio, Charles, Sentry, Firebase и др.) — [docs/practices-step-by-step.md](docs/practices-step-by-step.md)
- **Куда вставлять DSN/API Key** (Sentry, AppMetrica) — один файл в коде, описание режимов запуска: [docs/STUDENT_ENV.md](docs/STUDENT_ENV.md)
- **Частые вопросы и ответы** (запуск, Charles, курсы, Sentry, тесты, Firebase) — [docs/FAQ.md](docs/FAQ.md)
- **Карта документации** (с чего начать, что где лежит) — [docs/README.md](docs/README.md)

## 📦 Работа из коробки и подстановка токенов

- **Из коробки:** `flutter pub get` и `flutter run` — приложение собирается и работает без ключей. Charles/Proxyman, Android Studio, Xcode, ADB, TestFlight и Android-дистрибуция — по инструкциям в [docs/practices/](docs/practices/) (ничего не нужно вставлять в код).
- **Только подставить токены в один файл:** [lib/config/student_env.dart](lib/config/student_env.dart) — переменные `sentryDsn` (практика 06 Sentry) и `appMetricaApiKey` (практика 07 AppMetrica). Пустые значения — приложение работает без инициализации Sentry/AppMetrica.
- **Firebase:** не в репозитории по умолчанию. Подключение по [docs/practices/00-firebase-setup.md](docs/practices/00-firebase-setup.md) и практикам 10–15 (конфиги `google-services.json` / `GoogleService-Info.plist`, пакеты в pubspec).

Подробный отчёт проверки: [docs/VERIFICATION_REPORT.md](docs/VERIFICATION_REPORT.md).

## 📋 Сдача практик и экзамен

**Что показать на созвоне, чек-листы по каждой практике** — в **[docs/exam-and-submission.md](docs/exam-and-submission.md)**. Там же: как готовиться, что сказать экзаменатору, итоговый чек-лист перед сдачей.

---

## 📋 Тестовая документация

В **[docs/testing/](docs/testing/)** — детальная документация для тестирования:

- **Фичи** — по каждой фиче: бизнес/функциональные/нефункциональные требования, роли, схема БД, диаграммы состояний ([features](docs/testing/features/)).
- **Тест-кейсы** — ручные сценарии и таблица автотестов по файлам ([test-cases.md](docs/testing/test-cases.md)).
- **Практики** — пошаговые инструкции в [docs/practices/](docs/practices/) (из тестовой доки — [testing/practices/README.md](docs/testing/practices/README.md) только ссылки туда).

**Критерии приёмки** практик для преподавателя: **[docs/acceptance-criteria/](docs/acceptance-criteria/)** — чек-листы по каждой практике.


## 📚 Практики по технологиям

Во всех практиках используется **одно приложение FinControl**. Технологии: Charles, Proxyman, Android Studio, Xcode, ADB, Sentry, AppMetrica, TestFlight, Android-дистрибуция, Firebase (настройка проекта + модули 10–15: Crashlytics, FCM, Analytics, Remote Config, Performance Monitoring, In-App Messaging). Полный список и рекомендуемый порядок: **[docs/practices/README.md](docs/practices/README.md)** и **[docs/practices-step-by-step.md](docs/practices-step-by-step.md)**.

| № | Практика |
|---|----------|
| — | [Перед началом](docs/practices/00-getting-started.md) — клонирование, первый запуск, Android Studio |
| 00 | [Firebase (настройка)](docs/practices/00-firebase-setup.md) — свой проект, подключение (iOS/Android); обязательно перед практиками 10–15 |
| 01 | [Charles](docs/practices/01-charles.md) — перехват трафика мобильного и веб-приложения |
| 02 | [Proxyman](docs/practices/02-proxyman.md) — перехват трафика мобильного и веб-приложения |
| 03 | [Android Studio](docs/practices/03-android-studio.md) — установка в эмуляторе, настройка Logcat |
| 04 | [Xcode](docs/practices/04-xcode.md) — установка в симуляторе iOS, логи в Console |
| 05 | [ADB](docs/practices/05-adb.md) — мануал по возможностям ADB на основе FinControl |
| 06 | [Sentry](docs/practices/06-sentry.md) — подключение Sentry SDK, события и краши |
| 07 | [AppMetrica](docs/practices/07-appmetrica.md) — SDK, заведение в AppMetrica, проверка устройств/сессий |
| 08 | [TestFlight](docs/practices/08-testflight.md) — iOS-приложение в TestFlight |
| 09 | [Android-дистрибуция](docs/practices/09-android-distribution.md) — Android-приложение в дистрибьютор (Google Play / Firebase App Distribution) |
| 10–15 | [Firebase-модули](docs/practices/README.md) — Crashlytics, FCM, Analytics, Remote Config, Performance, In-App Messaging |

---

## ⭐ Задание под звёздочкой

В приложении **специально оставлены 5 багов** разной сложности (лёгкие, средние, сложный). Задание: **найти их самостоятельно** — без подсказок, где именно они находятся. Опишите шаги воспроизведения, ожидаемое и фактическое поведение, по возможности укажите экран или сценарий. Задание выполняется по желанию, для зачёта или бонуса — на усмотрение преподавателя.


## 🧭 Структура проекта

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── student_env.dart        # ВАЖНО: сюда вставлять DSN/API Key по практикам (капсом подписано)
│   └── telemetry.dart          # реэкспорт из student_env (Sentry, AppMetrica)
├── core/                       # routes, app_theme, app_router, categories, formatters
├── data/                       # db, category_store
├── domain/
│   ├── models/                 # expense, exchange_operation, portfolio_holding, portfolio_transaction, limit_order, price_alert, savings_goal
│   └── repositories/          # expense_repository, exchange_repository, portfolio_repository, limit_orders_repository, price_alerts_repository, savings_goal_repository
├── services/                   # rates_api, stocks_api, crypto_api (курсы валют/акций — провайдеры + кэш)
├── state/                      # app_state, app_scope, theme_controller
└── ui/
    ├── screens/                # welcome_screen, shell_screen, home_screen, add_edit_screen, stats_screen, settings_screen, photo_viewer_screen, exchange_screen, portfolio_screen, stocks_screen
    └── widgets/                # app_bar_title, primary_button, summary_card, expense_tile, bar_row, rates_card, savings_goal_card, candlestick_chart, settings_action, theme_action, section_title
```

**Архитектура:** UI → state/domain → data; сервисы (HTTP) отдельно; форматирование в `core/formatters.dart`. Подробнее: [docs/technical/architecture.md](docs/technical/architecture.md).

### Внешний вид приложения

Тема (светлая/тёмная), цвета, шрифты и общий стиль карточек/полей задаются в **`lib/core/app_theme.dart`**: там настроены Material 3, `cardTheme`, `inputDecorationTheme`, `textTheme` и `appBarTheme`. Там же определены константы отступов (`screenPadding`, `sectionSpacing`, `cardContentPadding`) для единообразия экранов. Переключение темы — в настройках приложения (иконка шестерёнки в AppBar); выбор сохраняется между запусками. Подробнее: [docs/FAQ.md](docs/FAQ.md) — раздел «Внешний вид приложения».


## 🚀 Быстрый старт

```bash
git clone https://github.com/Valerijkk/fin_control.git
cd fin_control
flutter pub get
flutter run
```

**Требования**: Flutter **3.x** ✅  •  Dart **3.x** ✅

**Запуск в Android Studio:** открывай **корневую папку проекта** (где лежит `pubspec.yaml`), а не папку `android/` — иначе будут сотни ошибок. Подробно: [docs/technical/ANDROID_STUDIO_LAUNCH.md](docs/technical/ANDROID_STUDIO_LAUNCH.md). Эмулятор (например Pixel 9) запускай из Device Manager, затем Run ▶.


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

Полноценный тестовый фреймворк: unit, widget, хелперы. Подробно — **[test/README.md](test/README.md)**.

Структура:

```
test/
├─ flutter_test_config.dart            # SQLite FFI, intl, SharedPreferences
├─ helpers/test_host.dart              # TestAppState, makeHost(), exp()
├─ unit/                               # formatters, rates, stocks_api
├─ ui/screens/                         # home, exchange, portfolio, stocks, shell, ...
└─ app_boot_test.dart
```

Запуск:

```bash
flutter test
flutter test test/unit/
flutter test test/ui/
```


## 💱 Курсы валют: как сделано

* Провайдеры: `exchangerate.host` → fallback `open.er-api.com`
* **Таймаут** каждого запроса — **5 с**; при неудаче — второй провайдер, затем кэш или ошибка
* Кэш последнего успешного ответа (`shared_preferences`), отображаем **офлайн** (есть отметка)
* **Медленная загрузка или таймаут?** Что проверить и что делать — в [docs/FAQ.md](docs/FAQ.md) (раздел «Курсы грузятся очень медленно или запрос обрывается по таймауту»).


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
* **`databaseFactory not initialized` в тестах** → в `test/flutter_test_config.dart` должны быть `sqfliteFfiInit()`, `databaseFactory = databaseFactoryFfi`, а также `initializeDateFormatting('ru_RU')` и `SharedPreferences.setMockInitialValues({})`.
* **`dependOnInheritedWidgetOfExactType... before initState`** → читать `AppScope.of(context)` только в `didChangeDependencies()` (исправлено).
* **Курсы «ошибка загрузки»** → покажется кэш с пометкой «офлайн», как только сеть даст ответ — обновится.
* **Курсы грузятся долго / таймаут** → таймаут 5 с на запрос, два провайдера, затем кэш. Проверить сеть/VPN; подробнее — [docs/FAQ.md](docs/FAQ.md).


## 📦 Основные зависимости

* `sqflite`, `path`
* `http`
* `image_picker`
* `intl`
* `shared_preferences`
* Интеграции для практик: `sentry_flutter`, `appmetrica_plugin` — **токены только в** `lib/config/student_env.dart`; Firebase — по [docs/practices/00-firebase-setup.md](docs/practices/00-firebase-setup.md) и практикам 10–15 (свои конфиги в проект)
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

**FinControl** — учебная инвестиционная платформа. Практики по Charles, Proxyman, Android Studio, Xcode, ADB, Sentry, AppMetrica, сборкам и Firebase — в [docs/practices](docs/practices/).