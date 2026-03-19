# 🏗️ Архитектура FinControl — учебная платформа (Flutter)

---

## 1. 🔍 Обзор

| Аспект | Описание |
|--------|----------|
| **Клиент** | Одно приложение **FinControl** на Flutter — для всех мобильных и веб-практик (Android, iOS, Web). Одна кодовая база, одни и те же экраны и интеграции |
| **Запуск** | Собирается и запускается из корня репозитория без дополнительной настройки; базовый функционал работает с локальной БД |
| **Интеграции** | Метрики и Firebase подключаются только подстановкой ключей — см. ниже |
| **Данные** | Локальные SQLite + кэш курсов в `shared_preferences` |
| **Сеть** | Только запросы к публичным API курсов валют (HTTPS). Трафик рассчитан на перехват Charles/Proxyman |

> 💡 **Токены и ключи:** Sentry и AppMetrica — в `lib/config/student_env.dart`; Firebase — конфиги проекта (`google-services.json`, `GoogleService-Info.plist`). Без ключей приложение работает без инициализации этих SDK. См. [STUDENT_ENV.md](../STUDENT_ENV.md).

Компоненты для практик: Sentry, AppMetrica, Firebase (Crashlytics, FCM, Analytics, Remote Config, Performance, In-App Messaging) подключаются через SDK в том же Flutter-приложении.

---

## 2. 📁 Структура проекта Flutter

> 📌 Актуальная структура — в папке `lib/`. Экраны и сервисы могут дополняться.

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
│   ├── stocks_api.dart         # экран акций
│   └── crypto_api.dart         # крипто-API
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
        ├── app_bar_title.dart
        ├── primary_button.dart
        ├── summary_card.dart
        ├── expense_tile.dart
        ├── bar_row.dart
        ├── rates_card.dart
        ├── candlestick_chart.dart
        ├── settings_action.dart
        ├── theme_action.dart
        ├── section_title.dart
        └── savings_goal_card.dart
```

---

## 3. 🗄️ Модели данных (SQLite)

### Существующие

| Таблица | Описание |
|---------|----------|
| **expenses** | Расходы/доходы (id, title, amount, category, isIncome, date, photoPath и т.д.) |
| **Категории** | Часть в коде (`core/categories.dart`), пользовательские в `shared_preferences` (`CategoryStore`) |

### Новые таблицы

| Таблица | Описание |
|---------|----------|
| **exchange_operations** | История операций обмена (id, createdAt, amountFrom, currencyFrom, amountTo, currencyTo, rateUsed) |
| **portfolio_holdings** | Виртуальный портфель по валютам (id, currency, amount, avgRate, updatedAt) |
| **portfolio_transactions** | История сделок (id, createdAt, type buy/sell, currency, amount, rate, totalInBaseCurrency) |
| **portfolio_balance** | Базовая валюта и виртуальный баланс (можно хранить в `shared_preferences`) |

> 💡 Подробная спецификация полей и индексов — в [data-models.md](data-models.md).

---

## 4. 🌐 API (внешние)

| Провайдер | URL | Назначение |
|-----------|-----|------------|
| `exchangerate.host` | `https://api.exchangerate.host/latest?base=RUB&symbols=USD,EUR` | Основной источник курсов |
| `open.er-api.com` | `https://open.er-api.com/v6/latest/RUB` | Fallback |

- Все запросы — GET по HTTPS, с заголовками `Accept` и `User-Agent`, чтобы трафик был однозначно виден в Charles/Proxyman
- Реализация: `lib/services/rates_api.dart`

---

## 5. 🧭 Навигация и маршруты

Маршруты заданы в `lib/core/routes.dart` и обрабатываются в `app_router.dart`:

| Маршрут | Экран |
|---------|-------|
| `/` | Welcome |
| `/home` | Shell (нижняя навигация) |
| `/add` | Добавление/редактирование записи |
| `/settings` | Настройки |
| `/photo` | Просмотр фото |
| `/exchange` | Обменник |
| `/stocks` | Акции |
| `/portfolio` | Портфель |

В shell (нижняя навигация): Список (расходы), Обменник, Акции, Портфель, Статистика.

---

## 6. 🔌 Интеграции для практик

| Интеграция | Описание |
|------------|----------|
| **Sentry** | Flutter SDK, инициализация в `main()`, тестовая кнопка «Отправить тестовое исключение» в настройках |
| **AppMetrica** | Flutter SDK (`appmetrica_sdk`), инициализация в `main()`, проверка сессий/устройств в кабинете |
| **Firebase** | Один проект, подключение Android и iOS. Модули: Crashlytics, FCM, Analytics, Remote Config, Performance, In-App Messaging. Инициализация в `main()` |

> 📌 Все Firebase-практики собраны в одном файле: [`docs/practices/10-firebase.md`](../practices/10-firebase.md).

---

## 7. ⚡ Производительность

- **Тяжёлые операции не блокируют UI:** запросы к SQLite, API курсов и API акций/крипты выполняются асинхронно (`Future`/`async`). `sqflite` выполняет запросы в фоновом потоке; сетевые вызовы и чтение кэша из `SharedPreferences` также асинхронны. Не запускай длительные синхронные вычисления на main isolate без `compute()`.

- **Метрики и регрессии:** для отслеживания скорости ключевых сценариев используется Firebase Performance Monitoring (раздел Performance в [`10-firebase.md`](../practices/10-firebase.md)): автоматические метрики (App start, сеть) и кастомный трейс загрузки курсов (`load_rates`). Рекомендуется сравнивать метрики между версиями.

- **Таймауты:** в `RatesApi` задан таймаут сетевого запроса (5 с); при медленной сети или недоступности API показывается кэш с пометкой «офлайн» или сообщение об ошибке.

---

## 8. 🔒 Безопасность и прокси

- Сертификаты Charles/Proxyman: на устройстве/эмуляторе устанавливается доверенный CA, трафик к API курсов расшифровывается прокси
- В коде не хранить секреты API (при добавлении ключа — через конфиг/переменные окружения)

---

## 9. 📝 Логирование

| Платформа | Описание |
|-----------|----------|
| **Android** | Стандартный вывод + logcat (фильтры по тегу приложения) |
| **iOS** | Вывод в консоль Xcode |
| **Общее** | При необходимости — обёртка над `debugPrint`/`logger` с тегом «FinControl» |

---

## 10. 📦 Сборки и дистрибуция

| Платформа | Описание |
|-----------|----------|
| **Android** | Сборка release (APK/AAB), подписание, загрузка в Google Play Internal testing или Firebase App Distribution |
| **iOS** | Сборка для симулятора и устройства, загрузка в TestFlight |

---

## 11. 📚 Документация

| Раздел | Описание |
|--------|----------|
| `docs/practices/` | 10 пошаговых практик: Charles, Proxyman, Android Studio, Xcode, ADB, Sentry, AppMetrica, TestFlight, Android-дистрибуция, Firebase |
| `docs/technical/` | [architecture.md](architecture.md), [data-models.md](data-models.md), [api-spec.md](api-spec.md), [ANDROID_STUDIO_LAUNCH.md](ANDROID_STUDIO_LAUNCH.md) |
| Корневой README | Цель проекта, ссылки на практики, требования (Flutter 3.x, настройка эмуляторов) |
