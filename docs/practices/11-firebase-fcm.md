# Практика: Firebase Cloud Messaging (FCM) — push-флоу

**Одно приложение** FinControl. **Сначала [00-firebase-setup.md](00-firebase-setup.md):** свой проект Firebase, конфиги в проект, `Firebase.initializeApp()`. Ключи Sentry/AppMetrica (практики 06–07) — в [STUDENT_ENV.md](../STUDENT_ENV.md), не здесь. Для iOS дополнительно — APNs в Apple Developer и ключ в Firebase. Затем шаги этой практики.

## Цель

Подключить FCM к приложению FinControl (твой проект Firebase): запрос разрешений, получение FCM-токена, обработка уведомлений в foreground/background. Отправить тестовое push из Firebase Console и убедиться, что приложение его получает.

## Важно: один проект Firebase

**Сначала выполни [00-firebase-setup.md](00-firebase-setup.md):** свой проект, свои конфиги (`google-services.json`, `GoogleService-Info.plist`), `Firebase.initializeApp()` в коде. Для iOS дополнительно нужна настройка APNs в Apple Developer и загрузка ключа в Firebase.

## Ожидаемый результат

- FCM инициализирован в приложении; разрешения запрошены (iOS); FCM-токен получается и выводится в лог (для теста можно отправить сообщение на этот токен).
- Из Firebase Console (Engage → Messaging) отправлено тестовое уведомление на устройство; приложение получает его (в foreground — через `onMessage`; в background — через системный трей).

## Что понадобится

- Ваш Firebase-проект (по [00-firebase-setup.md](00-firebase-setup.md))
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

## Проверка

- [ ] Выполнен [00-firebase-setup.md](00-firebase-setup.md).
- [ ] Разрешения запрошены (iOS); FCM-токен получается и выводится в лог (например `debugPrint('FCM Token: $token')`).
- [ ] Тестовое сообщение из Firebase Console (Engage → Messaging) доставлено в приложение на выбранное устройство (по токену или тестовой группе).
- [ ] При открытии уведомления срабатывает обработчик (если настроен).

## Траблшутинг

- **Уведомления не приходят** — проверь, что FCM-токен выводится в лог и подставлен в консоль при отправке; на iOS — настроены APNs и ключ в Firebase. [FAQ — Firebase](../FAQ.md#firebase).

## Практические сценарии FCM в FinControl

### Сценарий 1: Получение и проверка FCM-токена

1. Запусти приложение с подключённым FCM.
2. В логах (`adb logcat | grep FCM` или Xcode Console) найди строку:
   ```
   FCM Token: eAbCd...очень_длинная_строка...xYz
   ```
3. Скопируй токен — он понадобится для отправки тестового push.
4. **Важно:** токен может меняться (при переустановке, обновлении Google Play Services). Используй `onTokenRefresh` для отслеживания.

### Сценарий 2: Отправка push из консоли

1. Firebase Console → **Engage → Messaging** → **Create your first campaign**.
2. Выбери **Firebase Notification messages**.
3. Заполни:
   - Заголовок: `Курсы обновлены!`
   - Текст: `USD: 92.50 ₽ (+0.5%). Откройте обменник.`
4. **Targeting → Single device** → вставь FCM-токен.
5. Отправь.
6. **Проверь:**
   - Если приложение в foreground — обработчик `onMessage` сработает (показать SnackBar или локальное уведомление).
   - Если в background — уведомление появится в системном трее.
   - При нажатии — `onMessageOpenedApp` сработает.

### Сценарий 3: Push с данными (deep link)

1. В консоли при создании push добавь **Custom data**:
   - Key: `action`, Value: `open_exchange`
   - Key: `currency`, Value: `USD`
2. В обработчике `onMessageOpenedApp`:
   ```dart
   if (message.data['action'] == 'open_exchange') {
     Navigator.of(context).pushNamed('/exchange');
   }
   ```
3. **Результат:** при нажатии на push приложение открывает экран Обменник.

## Что показать на экзамене / созвоне

1. Покажи в логах FCM-токен (debugPrint).
2. Открой Firebase Console → Engage → Messaging → создай тестовое уведомление.
3. Отправь на устройство по токену.
4. Покажи: уведомление пришло (в foreground — через обработчик onMessage; в background — в системном трее).
5. Нажми на уведомление — приложение открывается (onMessageOpenedApp).
6. Кратко скажи: «Подключил FCM, получил токен, отправил тестовый push из консоли — уведомление пришло и обрабатывается в обоих режимах.»

## Дополнительно: сценарии для FinControl

### Data Messages vs Notification Messages
- **Notification Messages** — показываются системой автоматически (в background).
- **Data Messages** — обрабатываются только кодом, не показываются автоматически.

В консоли Firebase при создании кампании можно добавить **Custom data** (key-value):
```
action: open_exchange
currency: USD
```
В обработчике:
```dart
FirebaseMessaging.onMessageOpenedApp.listen((message) {
  if (message.data['action'] == 'open_exchange') {
    Navigator.of(context).pushNamed('/exchange');
  }
});
```

### Topic Messaging
Подпиши устройство на тему и отправляй push по группам:
```dart
await FirebaseMessaging.instance.subscribeToTopic('rate_alerts');
```
В консоли Firebase отправь push на тему `rate_alerts` — все подписанные получат.

## Ссылки

- [00-firebase-setup.md](00-firebase-setup.md) — обязательно перед этой практикой
- [Критерии приёмки 11 — Firebase FCM](../acceptance-criteria/11-firebase-fcm.md)
- [FAQ — Firebase](../FAQ.md#firebase)
- [Список практик](README.md)
