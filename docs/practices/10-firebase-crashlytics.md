# Практика: Firebase Crashlytics — стабильность релиза

**Одно приложение** FinControl. **Сначала [00-firebase-setup.md](00-firebase-setup.md):** свой проект Firebase, конфиги (`google-services.json`, `GoogleService-Info.plist`) в проект, `Firebase.initializeApp()` в коде. Ключи Sentry/AppMetrica — в [STUDENT_ENV.md](../STUDENT_ENV.md), не здесь. Затем шаги этой практики — остальное из коробки (пакет + код по шагам ниже).

## Цель

Подключить Firebase Crashlytics к приложению FinControl (твой проект Firebase) и отслеживать падения и нефатальные ошибки: тестовый краш или записанная ошибка должны появиться в Firebase Console → Crashlytics → Issues.

## Важно: один проект Firebase для приложения

**Сначала выполни [00-firebase-setup.md](00-firebase-setup.md):** зарегистрируй свой проект в Firebase Console, добавь приложение FinControl (Android/iOS), скачай и положи в проект **свои** `google-services.json` и `GoogleService-Info.plist`, вызови в коде `Firebase.initializeApp()`. Конфиги Firebase — не в `student_env.dart`; ключи Sentry/AppMetrica (практики 06–07) задаются в [STUDENT_ENV.md](../STUDENT_ENV.md). Без выполненного [00-firebase-setup.md](00-firebase-setup.md) Crashlytics не заработает.

## Ожидаемый результат

- Crashlytics подключён в коде (перехват Flutter-ошибок и `runZonedGuarded`); тестовый краш или `recordError` отправляются в ваш проект Firebase.
- В Firebase Console → **Crashlytics** → **Issues** появляется отчёт с стек-трейсом, устройством и контекстом; по отчёту можно понять место в коде и стабильность релиза.

## Что понадобится

- Ваш Firebase-проект с подключённым приложением (по шагам из [00-firebase-setup.md](00-firebase-setup.md))
- Добавьте в `pubspec.yaml` при необходимости `firebase_crashlytics` (совместимую с firebase_core)

## Шаг 1: Подключение Crashlytics в проекте

1. Убедитесь, что в `main.dart` уже вызван `Firebase.initializeApp()` (по [00-firebase-setup.md](00-firebase-setup.md)).
2. Добавьте в `pubspec.yaml`: `firebase_crashlytics: ^4.0.0` (и `firebase_core`, если ещё не добавляли по [00-firebase-setup.md](00-firebase-setup.md)). Выполните `flutter pub get`.
3. В `lib/main.dart` после `Firebase.initializeApp()` добавьте:
   ```dart
   import 'package:firebase_crashlytics/firebase_crashlytics.dart';

   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     FlutterError.onError = (details) {
       FirebaseCrashlytics.instance.recordFlutterFatalError(details);
     };
     runZonedGuarded<Future<void>>(() async {
       runApp(const FinControlRoot());
     }, (error, stack) {
       FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
     });
   }
   ```

## Шаг 2: Тестовый краш

Добавьте в настройках (или на отдельной debug-кнопке) вызов:

```dart
FirebaseCrashlytics.instance.crash();
```

Либо намеренно вызовите исключение в коде и не перехватывайте его — Crashlytics отправит отчёт после перезапуска приложения.

## Шаг 3: Нефатальные ошибки

Для логирования нефатальных ошибок (например ошибка сети):

```dart
FirebaseCrashlytics.instance.recordError(
  exception,
  stackTrace,
  reason: 'Ошибка загрузки курсов',
  fatal: false,
);
```

## Шаг 4: Просмотр в Firebase Console

1. Откройте [Firebase Console](https://console.firebase.google.com) → ваш проект → **Crashlytics**.
2. После первого краша или записи ошибки (и перезапуска приложения) отчёт появится в разделе **Issues**.
3. Откройте issue: видны стек-трейс, устройство, версия ОС, количество затронутых пользователей — это и есть «стабильность релиза».

## Проверка

- [ ] Выполнен [00-firebase-setup.md](00-firebase-setup.md): в проекте ваши конфиги Firebase, вызывается `Firebase.initializeApp()`.
- [ ] Crashlytics подключён в коде; нефатальные и фатальные ошибки перехватываются и отправляются.
- [ ] Тестовый краш (`FirebaseCrashlytics.instance.crash()`) или записанная ошибка отображаются в Firebase Console → **Crashlytics** → Issues (после перезапуска приложения при фатальном краше).
- [ ] В отчёте видны стек-трейс, устройство, контекст падения.

## Траблшутинг

- **Crashlytics не видит крашей** — убедись, что выполнен [00-firebase-setup.md](00-firebase-setup.md), конфиги в проекте, `Firebase.initializeApp()` вызывается до Crashlytics. После фатального краша отчёт отправляется при следующем запуске приложения.
- **Firebase:** [FAQ — Firebase](../FAQ.md#firebase).

## Практические сценарии Crashlytics

### Сценарий 1: Тестовый краш и анализ отчёта

1. Добавь в Настройки кнопку (или используй существующую) для вызова `FirebaseCrashlytics.instance.crash()`.
2. Нажми — приложение упадёт.
3. **Перезапусти** приложение (Crashlytics отправляет отчёт при следующем запуске).
4. Открой Firebase Console → **Crashlytics** → **Issues**.
5. Найди issue — открой:
   - **Stack trace** — точное место краша.
   - **Device** — модель, ОС, свободная память.
   - **Keys** — кастомные ключи (если добавлены).
   - **Logs** — логи перед крашем.
   - **Affected users** — количество затронутых пользователей.

### Сценарий 2: Нефатальная ошибка с контекстом

1. При ошибке загрузки курсов (offline) запиши нефатальную ошибку:
   ```dart
   FirebaseCrashlytics.instance.setCustomKey('screen', 'exchange');
   FirebaseCrashlytics.instance.setCustomKey('action', 'load_rates');
   FirebaseCrashlytics.instance.recordError(error, stack, reason: 'Ошибка загрузки курсов');
   ```
2. В Firebase Console → Crashlytics → Issues — ошибка появится как **Non-fatal**.
3. Открой — увидишь кастомные ключи `screen: exchange`, `action: load_rates`.
4. **Зачем:** в реальном проекте это помогает понять, на каком экране и при каком действии происходят ошибки.

### Сценарий 3: Отслеживание Crash-Free Users

1. После нескольких запусков без крашей проверь **Dashboard** → **Crash-free users**.
2. Значение должно быть ~100% (нет крашей).
3. Сделай краш → перезапусти → процент упадёт.
4. **Зачем:** в реальных проектах Crash-free users > 99.5% считается хорошим показателем. Ниже 99% — критично.

## Что показать на экзамене / созвоне

1. Покажи Firebase Console → свой проект → **Crashlytics**.
2. В приложении вызови тестовый краш (кнопка или код) → перезапусти приложение.
3. В Crashlytics → Issues покажи появившийся отчёт.
4. Открой issue: покажи стек-трейс, устройство, версию ОС.
5. Покажи нефатальную ошибку (recordError) — она должна быть в списке Issues отдельно.
6. Кратко скажи: «Подключил Crashlytics, настроил перехват Flutter-ошибок и runZonedGuarded. Тестовый краш и нефатальная ошибка видны в консоли с полным контекстом.»

## Дополнительно: сценарии тестирования Crashlytics в FinControl

### Сценарий 1: Краш при конвертации валюты
Добавь тестовый краш при обмене с нулевым курсом — Crashlytics поймает и покажет стек.

### Сценарий 2: Нефатальная ошибка сети
При ошибке загрузки курсов (offline, таймаут) запиши нефатальную ошибку через `recordError` с контекстом:
```dart
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'Ошибка загрузки курсов: offline',
  fatal: false,
);
```

### Сценарий 3: Custom Keys
Добавь ключи для контекста перед потенциально опасной операцией:
```dart
FirebaseCrashlytics.instance.setCustomKey('screen', 'exchange');
FirebaseCrashlytics.instance.setCustomKey('currency_pair', 'RUB/USD');
FirebaseCrashlytics.instance.setCustomKey('amount', amountText);
```
В отчёте Crashlytics увидишь эти ключи — поможет воспроизвести баг.

### Сценарий 4: Crash-Free Users
В Firebase Console → Crashlytics → Dashboard — показатель **Crash-free users** (процент пользователей без крашей). Это ключевая метрика стабильности релиза.

## Ссылки

- [00-firebase-setup.md](00-firebase-setup.md) — обязательно перед этой практикой
- [Критерии приёмки 10 — Firebase Crashlytics](../acceptance-criteria/10-firebase-crashlytics.md)
- [FAQ — Firebase](../FAQ.md#firebase)
- [Список практик](README.md)
