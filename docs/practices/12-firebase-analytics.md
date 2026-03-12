# Практика: Firebase Analytics — события и воронки

## Цель

Включить Firebase Analytics в FinControl, логировать ключевые события (открытие экранов, обмен, сделка в портфеле) и посмотреть их в консоли Firebase: стандартные отчёты и воронки.

## Важно: свой проект Firebase

**Сначала [00-firebase-setup.md](00-firebase-setup.md):** свой проект, свои конфиги, `Firebase.initializeApp()` в коде.

## Что понадобится

- Ваш Firebase-проект с подключённым приложением
- Добавьте в `pubspec.yaml` при необходимости `firebase_analytics` (совместимую с firebase_core)

## Шаг 1: Подключение

Добавьте при необходимости `firebase_analytics` в `pubspec.yaml`, выполните `flutter pub get`. Analytics обычно включается автоматически после `Firebase.initializeApp()` (по 00-firebase-setup.md). Для явной настройки:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;
```

## Шаг 2: Логирование событий

Рекомендуется логировать переходы по экранам и ключевые действия.

**Экраны (автоматически при использовании FirebaseAnalyticsObserver):**

```dart
MaterialApp(
  navigatorObservers: [
    FirebaseAnalyticsObserver(analytics: analytics),
  ],
  ...
);
```

Или вручную при открытии экрана:

```dart
await analytics.logScreenView(screenName: 'ExchangeScreen', screenClass: 'ExchangeScreen');
```

**Кастомные события** (обмен, сделка в портфеле):

```dart
await analytics.logEvent(
  name: 'exchange_completed',
  parameters: {
    'currency_from': 'RUB',
    'currency_to': 'USD',
    'amount': 1000,
  },
);

await analytics.logEvent(
  name: 'portfolio_buy',
  parameters: {'currency': 'USD', 'amount': 100},
);
```

Добавьте такие вызовы в коде после успешного обмена и после покупки/продажи в портфеле.

## Шаг 3: Просмотр в Firebase Console

1. **Analytics** → **Events** — список событий и количество срабатываний.
2. **DebugView** (включите в приложении через `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true)` и в консоли **DebugView** → добавьте устройство по дебаг-токену) — события в реальном времени.
3. **Funnel analysis** / **Exploration** — постройте воронку, например: `screen_view (Welcome)` → `screen_view (Home)` → `exchange_completed` или `portfolio_buy`.

## Что проверить (чек-лист)

- [ ] События вызываются в коде при действиях пользователя.
- [ ] В разделе Events (или DebugView) видны ваши события.
- [ ] Можно построить простую воронку по экранам и действиям.
