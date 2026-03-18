# Практика: Firebase Analytics — события и воронки

**Одно приложение** FinControl. **Сначала [00-firebase-setup.md](00-firebase-setup.md):** свой проект Firebase, конфиги в проект, `Firebase.initializeApp()`. Ключи Sentry/AppMetrica (практики 06–07) — в [STUDENT_ENV.md](../STUDENT_ENV.md), не здесь. Затем включаешь Analytics и логируешь события по шагам ниже — смотришь в консоли Events / DebugView и строишь воронки.

## Цель

Включить Firebase Analytics в приложении FinControl (твой проект Firebase), логировать ключевые события (открытие экранов, обмен, сделка в портфеле) и посмотреть их в Firebase Console: раздел Events (или DebugView для реального времени) и при необходимости воронки.

## Важно: один проект Firebase

**Сначала [00-firebase-setup.md](00-firebase-setup.md):** свой проект, свои конфиги, `Firebase.initializeApp()` в коде. Ключи Sentry/AppMetrica (практики 06–07) — в [STUDENT_ENV.md](../STUDENT_ENV.md), не здесь.

## Ожидаемый результат

- События вызываются в коде при действиях пользователя (`screen_view`, `exchange_completed`, `portfolio_buy` и т.п.).
- В Firebase Console → **Analytics** → **Events** (или **DebugView** при включённой отладке) видны ваши события.
- Можно построить простую воронку по экранам и действиям (например Welcome → Home → exchange_completed).

## Что понадобится

- Ваш Firebase-проект с подключённым приложением
- Добавьте в `pubspec.yaml` при необходимости `firebase_analytics` (совместимую с firebase_core)

## Шаг 1: Подключение

Добавьте при необходимости `firebase_analytics` в `pubspec.yaml`, выполните `flutter pub get`. Analytics обычно включается автоматически после `Firebase.initializeApp()` (по [00-firebase-setup.md](00-firebase-setup.md)). Для явной настройки:

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

## Проверка

- [ ] Выполнен [00-firebase-setup.md](00-firebase-setup.md).
- [ ] События вызываются в коде при действиях пользователя (открытие экранов, обмен, портфель).
- [ ] В Firebase Console → **Analytics** → **Events** (или **DebugView**) видны ваши события.
- [ ] Построена простая воронка по экранам и действиям.

## Траблшутинг

- **События не видны** — проверь, что выполнен [00-firebase-setup.md](00-firebase-setup.md) и события вызываются в коде; для реального времени включи DebugView и добавь устройство по дебаг-токену. [FAQ — Firebase](../FAQ.md#firebase).

## Что показать на экзамене / созвоне

1. Покажи код: вызовы `logEvent` и `logScreenView` в приложении.
2. Выполни действия: открой Обменник, сделай обмен, открой Портфель, купи валюту.
3. Открой Firebase Console → Analytics → **DebugView** — покажи события в реальном времени.
4. Открой **Events** — покажи список событий с количеством срабатываний.
5. Покажи построенную воронку (если доступно в Exploration).
6. Кратко скажи: «Подключил Analytics, логирую экраны и ключевые действия. В DebugView вижу события в реальном времени, в Events — статистику.»

## Дополнительно: рекомендуемые события для FinControl

| Событие | Когда срабатывает | Параметры |
|---------|-------------------|-----------|
| `screen_view` | Открытие любого экрана | `screen_name`, `screen_class` |
| `expense_added` | Добавление расхода/дохода | `category`, `amount`, `is_income` |
| `exchange_completed` | Конвертация валюты | `currency_from`, `currency_to`, `amount` |
| `portfolio_buy` | Покупка валюты/акций в портфеле | `currency`, `amount`, `rate` |
| `portfolio_sell` | Продажа из портфеля | `currency`, `amount`, `rate` |
| `alert_created` | Создание ценового алерта | `currency_pair`, `target_rate` |
| `goal_created` | Создание цели накоплений | `title`, `target_amount` |
| `theme_toggled` | Переключение темы | `theme` (`light`/`dark`) |
| `data_cleared` | Очистка всех данных | — |

### DebugView — события в реальном времени

Для просмотра событий без задержки:

**Android:**
```bash
adb shell setprop debug.firebase.analytics.app com.yourname.fincontrol.fin_control
```

**iOS:**
В Xcode добавь аргумент запуска: `-FIRDebugEnabled`.

После этого события появляются в Firebase Console → Analytics → **DebugView** мгновенно.

## Ссылки

- [00-firebase-setup.md](00-firebase-setup.md) — обязательно перед этой практикой
- [Критерии приёмки 12 — Firebase Analytics](../acceptance-criteria/12-firebase-analytics.md)
- [FAQ — Firebase](../FAQ.md#firebase)
- [Список практик](README.md)
