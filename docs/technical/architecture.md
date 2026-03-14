# Архитектура FinControl — учебная платформа (Flutter)

## 1. Обзор

- **Клиент**: одно приложение **FinControl** на Flutter — для всех мобильных и веб-практик (Android, iOS, при необходимости Web). Одна кодовая база, одни и те же экраны и интеграции. Актуальная структура — в `lib/`.
- **Запуск из коробки:** приложение собирается и запускается из корня репозитория без дополнительной настройки; базовый функционал (расходы, обменник, портфель, статистика) работает с локальной БД.
- **Интеграции по токенам:** метрики и Firebase подключаются только подстановкой ключей в указанный файл: Sentry и AppMetrica — в `lib/config/student_env.dart`; Firebase — конфиги проекта (`google-services.json`, `GoogleService-Info.plist`). Без ключей приложение корректно работает без инициализации этих SDK. См. [STUDENT_ENV.md](../STUDENT_ENV.md).
- **Данные**: локальные SQLite (расходы, категории, история обмена, портфель/сделки) + кэш курсов в shared_preferences.
- **Сеть**: только запросы к публичным API курсов валют (HTTPS). Трафик рассчитан на перехват Charles/Proxyman.

Компоненты для практик: Sentry, AppMetrica, Firebase (Crashlytics, FCM, Analytics, Remote Config, Performance, In-App Messaging) подключаются через SDK в том же Flutter-приложении.

---

## 2. Структура проекта Flutter

Актуальная структура — в папке `lib/`. Ниже — ориентировочная схема; экраны и сервисы могут дополняться (например Акции, крипто-API).

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── student_env.dart        # DSN/API Key по практикам (не коммитить секреты)
│   └── telemetry.dart          # Sentry, AppMetrica
├── core/
│   ├── routes.dart
│   ├── app_theme.dart
│   ├── app_router.dart
│   ├── categories.dart
│   └── formatters.dart
├── data/
│   ├── db.dart
│   └── category_store.dart
├── domain/
│   ├── models/
│   │   ├── expense.dart
│   │   ├── exchange_operation.dart
│   │   ├── portfolio_holding.dart
│   │   ├── portfolio_transaction.dart
│   │   ├── price_alert.dart
│   │   ├── limit_order.dart
│   │   └── savings_goal.dart
│   └── repositories/
│       ├── expense_repository.dart
│       ├── exchange_repository.dart
│       ├── portfolio_repository.dart
│       ├── price_alerts_repository.dart
│       ├── limit_orders_repository.dart
│       └── savings_goal_repository.dart
├── services/
│   ├── rates_api.dart          # курсы валют
│   ├── stocks_api.dart         # при наличии экрана акций
│   └── crypto_api.dart         # при наличии
├── state/
│   ├── app_state.dart
│   ├── app_scope.dart
│   └── theme_controller.dart
└── ui/
    ├── screens/
    │   ├── welcome_screen.dart
    │   ├── shell_screen.dart
    │   ├── home_screen.dart
    │   ├── add_edit_screen.dart
    │   ├── stats_screen.dart
    │   ├── settings_screen.dart
    │   ├── photo_viewer_screen.dart
    │   ├── exchange_screen.dart
    │   ├── stocks_screen.dart
    │   └── portfolio_screen.dart
    └── widgets/
        └── app_bar_title, primary_button, summary_card, expense_tile, bar_row, rates_card, candlestick_chart, settings_action, theme_action, section_title, savings_goal_card
```

---

## 3. Модели данных (SQLite)

### 3.1 Существующие

- **expenses** — расходы/доходы (id, title, amount, category, isIncome, date, photoPath и т.д.)
- Категории — часть в коде (core/categories.dart), пользовательские в shared_preferences (CategoryStore).

### 3.2 Новые таблицы

- **exchange_operations**  
  - id, createdAt, amountFrom, currencyFrom, amountTo, currencyTo, rateUsed  
  - Для истории операций обмена и тестирования сценариев.

- **portfolio_holdings**  
  - id, currency (например USD/EUR), amount, avgRate (средняя цена входа в базовой валюте), updatedAt  
  - Виртуальный портфель по валютам.

- **portfolio_transactions**  
  - id, createdAt, type (buy/sell), currency, amount, rate, totalInBaseCurrency  
  - История сделок для отчётов и тестов.

- **portfolio_balance** (или одно поле в настройках)  
  - Базовая валюта (RUB/USD/EUR) и начальный виртуальный баланс — можно хранить в одной строке в отдельной таблице или в shared_preferences.

---

## 4. API (внешние)

- **Курсы валют**: уже используются `exchangerate.host` и `open.er-api.com` (RatesApi в services/rates_api.dart).
- Все запросы — GET по HTTPS, с заголовками Accept и User-Agent, чтобы трафик был однозначно виден в Charles/Proxyman.
- При необходимости добавить вызов ещё одного публичного API (например для расширенного списка валют) — без изменения общей схемы.

---

## 5. Навигация и маршруты

- Маршруты заданы в `lib/core/routes.dart` и обрабатываются в `app_router.dart`: `/` (welcome), `/home` (shell), `/add`, `/settings`, `/photo`, `/exchange`, `/stocks`, `/portfolio`.
- В shell (нижняя навигация) — пункты: Список (расходы), Обменник, Акции, Портфель, Статистика.

---

## 6. Интеграции для практик

- **Sentry**: Flutter SDK, инициализация в main(), опционально тестовый кнопка «Отправить тестовое исключение» в настройках/debug.
- **AppMetrica**: Flutter SDK (например appmetrica_sdk), инициализация в main(), заведение приложения в кабинете AppMetrica; проверка появления сессий/устройств.
- **Firebase**: один проект, подключение Android и iOS (google-services.json / GoogleService-Info.plist), модули:
  - Crashlytics
  - FCM (push)
  - Analytics
  - Remote Config (фичефлаги для включения/выключения экранов или опций)
  - Performance Monitoring
  - In-App Messaging  
  Инициализация в main(), при необходимости условная по платформе.

---

## 7. Производительность

- **Тяжёлые операции не блокируют UI:** запросы к SQLite (`data/db.dart`), к API курсов (`services/rates_api.dart`) и к API акций/крипты (`services/stocks_api.dart`, `services/crypto_api.dart`) выполняются асинхронно (`Future`/`async`). sqflite выполняет запросы в фоновом потоке; сетевые вызовы и чтение кэша из SharedPreferences также асинхронны. Не запускайте длительные синхронные вычисления на main isolate без `compute()`.
- **Метрики и регрессии:** для отслеживания скорости ключевых сценариев используется Firebase Performance Monitoring (практика [14-firebase-performance](../practices/14-firebase-performance.md)): автоматические метрики (App start, сеть) и кастомный трейс загрузки курсов (`load_rates`). Рекомендуется сравнивать метрики между версиями приложения, чтобы выявлять регрессии по скорости.
- **Таймауты:** в `RatesApi` задан таймаут сетевого запроса (5 с); при медленной сети или недоступности API показывается кэш с пометкой «офлайн» или сообщение об ошибке. Рекомендации для пользователя при медленной загрузке — в [FAQ](../FAQ.md) и [README](../../README.md).

---

## 8. Безопасность и прокси

- Сертификаты Charles/Proxyman: на устройстве/эмуляторе устанавливается доверенный CA, трафик к API курсов расшифровывается прокси — стандартная практика при настройке прокси.
- В коде не хранить секреты API (публичные API курсов обычно по ключу или без; при добавлении ключа — через конфиг/переменные окружения).

---

## 9. Логирование

- Android: стандартный вывод + logcat (документация в практиках: фильтры по тегу приложения).
- iOS: вывод в консоль Xcode (документация в практиках).
- При необходимости — обёртка над debugPrint/logger с тегом «FinControl» для удобной фильтрации.

---

## 10. Сборки и дистрибуция

- **Android**: сборка release (APK/AAB), подписание, загрузка в выбранный дистрибьютор (Google Play Internal testing или Firebase App Distribution) — шаги в практиках.
- **iOS**: сборка для симулятора и устройство, загрузка в TestFlight — шаги в практиках.

---

## 11. Документация

- **docs/practices/** — пошаговые практики: Charles, Proxyman, Android Studio, Xcode, ADB, Sentry, AppMetrica, сборки (TestFlight, Android), Firebase (все перечисленные модули).
- **docs/technical/** — [architecture.md](architecture.md), [data-models.md](data-models.md), [api-spec.md](api-spec.md), [ANDROID_STUDIO_LAUNCH.md](ANDROID_STUDIO_LAUNCH.md).
- **Корневой README** — цель проекта, ссылки на практики, требования (Flutter 3.x, настройка эмуляторов).
