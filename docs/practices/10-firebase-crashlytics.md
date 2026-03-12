# Практика: Firebase Crashlytics — стабильность релиза

## Цель

Подключить Firebase Crashlytics к приложению FinControl и научиться отслеживать падения и нефатальные ошибки для оценки стабильности релиза.

## Важно: свой проект Firebase

**Сначала выполните [00-firebase-setup.md](00-firebase-setup.md):** зарегистрируйте свой проект в Firebase Console, добавьте приложение (Android/iOS), скачайте и поместите в проект **свои** `google-services.json` и `GoogleService-Info.plist`, включите в коде `Firebase.initializeApp()`. Без этого Crashlytics не заработает.

## Что понадобится

- Ваш Firebase-проект с подключённым приложением (по шагам из 00-firebase-setup.md)
- Добавьте в `pubspec.yaml` при необходимости `firebase_crashlytics` (совместимую с firebase_core)

## Шаг 1: Подключение Crashlytics в проекте

1. Убедитесь, что в `main.dart` уже вызван `Firebase.initializeApp()` (по [00-firebase-setup.md](00-firebase-setup.md)).
2. Добавьте в `pubspec.yaml`: `firebase_crashlytics: ^4.0.0` (и `firebase_core`, если ещё не добавляли по 00-firebase-setup.md). Выполните `flutter pub get`.
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

## Что проверить (чек-лист)

- [ ] Crashlytics подключён, нефатальные и фатальные ошибки перехватываются.
- [ ] Тестовый краш или записанная ошибка отображаются в Firebase Crashlytics.
- [ ] По отчёту можно понять место в коде и контекст падения.
