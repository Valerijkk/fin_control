# Архитектура FinControl — учебная платформа (Flutter)

## 1. Обзор

- **Клиент**: одно приложение Flutter (Android, iOS, при необходимости Web).
- **Данные**: локальные SQLite (расходы, категории, история обмена, портфель/сделки) + кэш курсов в shared_preferences.
- **Сеть**: только запросы к публичным API курсов валют (HTTPS). Трафик рассчитан на перехват Charles/Proxyman.

Компоненты для практик тестировщиков: Sentry, AppMetrica, Firebase (Crashlytics, FCM, Analytics, Remote Config, Performance, In-App Messaging) подключаются через SDK в том же Flutter-приложении.

---

## 2. Структура проекта Flutter

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── routes.dart
│   ├── app_theme.dart
│   ├── app_router.dart
│   ├── categories.dart
│   └── formatters.dart
├── data/
│   ├── db.dart                 # SQLite: расходы, таблицы обмена/портфеля
│   ├── category_store.dart
│   └── (при необходимости) exchange_store.dart / portfolio_store.dart
├── domain/
│   ├── models/
│   │   ├── expense.dart
│   │   ├── exchange_operation.dart   # новая сущность
│   │   └── portfolio_holding.dart   # новая сущность
│   └── repositories/
│       ├── expense_repository.dart
│       ├── exchange_repository.dart  # новая
│       └── portfolio_repository.dart # новая
├── services/
│   └── rates_api.dart          # существующий, доработать при необходимости
├── state/
│   ├── app_state.dart          # расширить под обмен и портфель или отдельные контроллеры
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
    │   ├── exchange_screen.dart   # новый — обменник
    │   └── portfolio_screen.dart  # новый — портфель
    └── widgets/
        ├── ... (существующие)
        ├── exchange_form.dart     # форма обмена
        └── portfolio_list.dart    # список активов
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

- Добавить маршруты: `/exchange` (обменник), `/portfolio` (портфель).
- В shell (bottom navigation или drawer) — пункты «Обменник» и «Портфель» рядом с «Расходы» и «Статистика».

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

## 7. Безопасность и прокси

- Сертификаты Charles/Proxyman: на устройстве/эмуляторе устанавливается доверенный CA, трафик к API курсов расшифровывается прокси — это стандартная практика для обучения тестировщиков.
- В коде не хранить секреты API (публичные API курсов обычно по ключу или без; при добавлении ключа — через конфиг/переменные окружения).

---

## 8. Логирование

- Android: стандартный вывод + logcat (документация в практиках: фильтры по тегу приложения).
- iOS: вывод в консоль Xcode (документация в практиках).
- При необходимости — обёртка над debugPrint/logger с тегом «FinControl» для удобной фильтрации.

---

## 9. Сборки и дистрибуция

- **Android**: сборка release (APK/AAB), подписание, загрузка в выбранный дистрибьютор (Google Play Internal testing или Firebase App Distribution) — шаги в практиках.
- **iOS**: сборка для симулятора и устройство, загрузка в TestFlight — шаги в практиках.

---

## 10. Документация

- **docs/practices/** — пошаговые практики для учеников: Charles, Proxyman, Android Studio, Xcode, ADB, Sentry, AppMetrica, сборки (TestFlight, Android), Firebase (все перечисленные модули).
- **README** — цель проекта (учебная платформа для тестировщиков), ссылки на практики, требования (Flutter 3.x, настройка эмуляторов).
