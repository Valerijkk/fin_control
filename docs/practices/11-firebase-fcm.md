# Практика: Firebase Cloud Messaging (FCM) — push-флоу

## Цель

Подключить FCM в приложении FinControl: запрос разрешений, получение токена, обработка уведомлений. Отправить тестовое push-уведомление из Firebase Console и проверить получение в приложении.

## Важно: свой проект Firebase

**Сначала выполните [00-firebase-setup.md](00-firebase-setup.md):** зарегистрируйте свой проект, добавьте свои конфиги (`google-services.json`, `GoogleService-Info.plist`) и `Firebase.initializeApp()` в коде.

## Что понадобится

- Ваш Firebase-проект (по 00-firebase-setup.md)
- Добавьте в `pubspec.yaml` зависимость `firebase_messaging` (актуальную версию смотрите на pub.dev, совместимую с вашим firebase_core)

## Шаг 1: Права и настройка платформ

1. Добавьте `firebase_messaging` в `pubspec.yaml`, выполните `flutter pub get`.

2. **iOS**: в Xcode включите **Push Notifications** и **Background Modes → Remote notifications**. В App Store Connect / Apple Developer настройте APNs ключ и загрузите его в Firebase (Project Settings → Cloud Messaging → Apple app configuration).

3. **Android**: в манифесте права на уведомления не обязательны для базового FCM, но для отображения канала нужен channel ID (Android 8+).

## Шаг 2: Инициализация и запрос разрешений

В `main.dart` после `Firebase.initializeApp()`:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Обработка фонового сообщения
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(); // iOS
  final token = await messaging.getToken();
  debugPrint('FCM Token: $token'); // для теста можно отправить уведомление по токену
  runApp(const FinControlRoot());
}
```

Обработка в foreground:

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Показать локальное уведомление или обновить UI
});
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Переход по данным из уведомления
});
```

## Шаг 3: Отправка тестового уведомления из консоли

1. Firebase Console → **Engage** → **Messaging** (или **Cloud Messaging**).
2. **Create your first campaign** или **New campaign** → **Firebase Notification messages**.
3. Введите заголовок и текст, выберите приложение (Android/iOS).
4. В **Targeting** выберите «Single device» и вставьте FCM-токен (скопированный из логов приложения) или отправьте на все тестовые устройства.
5. Отправьте. Приложение должно получить уведомление (в foreground — через `onMessage`; в background — через системный трей).

## Что проверить

- [ ] Разрешения запрошены, токен получается и выводится в лог.
- [ ] Тестовое сообщение из консоли доставлено в приложение.
- [ ] При открытии уведомления срабатывает обработчик (если настроен).
