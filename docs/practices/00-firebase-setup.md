# Firebase: регистрация проекта и подключение к FinControl

Все практики по Firebase (Crashlytics, FCM, Analytics, Remote Config, Performance, In-App Messaging) требуют **вашего собственного** проекта Firebase. **Одно приложение** FinControl: регистрируешь его в своей консоли Firebase и подставляешь **только конфиги** в проект (`google-services.json`, `GoogleService-Info.plist`). Ключи Sentry и AppMetrica для практик 06–07 задаются не здесь, а в [STUDENT_ENV.md](../STUDENT_ENV.md) → `lib/config/student_env.dart`.

---

## Цель

Зарегистрировать свой проект в Firebase Console, добавить в него приложение FinControl (Android и при необходимости iOS), скачать конфиги и положить их в проект, подключить Firebase в коде так, чтобы практики 10–15 работали с твоей консолью.

## Ожидаемый результат

- В [Firebase Console](https://console.firebase.google.com) есть твой проект с зарегистрированными приложениями Android и/или iOS (package name / Bundle ID совпадают с FinControl).
- В проекте лежат **твои** файлы: `android/app/google-services.json` и при необходимости `ios/Runner/GoogleService-Info.plist`.
- В `lib/main.dart` перед `runApp(...)` вызывается `Firebase.initializeApp()`; приложение запускается без ошибки «No Firebase App '[DEFAULT]' has been created».

---

## Шаг 1: Создать проект в Firebase

1. Открой в браузере [console.firebase.google.com](https://console.firebase.google.com) и войди через Google-аккаунт.
2. Нажми **Создать проект** (или **Add project**).
3. Укажи название (например `fin-control-practice`), при необходимости отключи или включи Google Analytics — на твоё усмотрение.
4. Дождись создания проекта. Окажешься в обзоре проекта.

## Шаг 2: Добавить приложение Android

1. В обзоре проекта нажми **Добавить приложение** → выбери иконку **Android**.
2. В поле **Package name** укажи идентификатор приложения FinControl:
   - открой в проекте файл **`android/app/build.gradle.kts`** и найди строку `applicationId = "..."`;
   - скопируй значение в кавычках (например `com.yourname.fincontrol.fin_control`) и вставь в форму Firebase.
3. Никнейм и SHA-1 можно не заполнять для начала (для FCM и подписи понадобятся в практиках 11 и 09).
4. Нажми **Зарегистрировать приложение**.
5. На странице «Скачать google-services.json» нажми **Скачать google-services.json**.
6. Перемести скачанный файл в папку **`android/app/`** проекта FinControl (рядом с `build.gradle.kts`). Имя файла должно остаться `google-services.json`.

**Безопасность:** не коммитьте в репозиторий конфиги с реальными ключами. Файлы `google-services.json` и `GoogleService-Info.plist` содержат идентификаторы и ключи проекта. В учебном проекте их можно держать локально; в реальных проектах не коммитьте их в публичный репозиторий (или добавьте в `.gitignore`, доставка через CI). Общая политика по ключам: [STUDENT_ENV.md](../STUDENT_ENV.md) (раздел «Безопасность ключей»).

## Шаг 3: Добавить приложение iOS (если нужна практика на iOS)

1. В обзоре проекта снова **Добавить приложение** → выбери **iOS**.
2. Укажи **Apple bundle ID** — он должен совпадать с Bundle Identifier в Xcode (открой `ios/Runner.xcworkspace` → Runner → General → Bundle Identifier). Обычно что-то вроде `com.yourname.fincontrol`.
3. Никнейм и App Store ID можно не заполнять для учебного проекта.
4. **Скачай** файл **GoogleService-Info.plist** и добавь его в проект Xcode в папку **Runner** (перетащи в `ios/Runner/` и отметь добавление в таргет Runner).

## Шаг 4: Добавить Firebase в проект и инициализировать

1. В корне проекта открой **`pubspec.yaml`**. В блок `dependencies` добавь (если ещё нет):
   ```yaml
   firebase_core: ^3.0.0
   ```
   В терминале из корня выполни: `flutter pub get`.

2. Настрой платформы (один раз) по [официальной документации Flutter Firebase](https://firebase.flutter.dev/docs/installation):
   - **Android**: в корневом `android/build.gradle.kts` — класс-путь `com.google.gms:google-services`; в `android/app/build.gradle.kts` в конец файла — `apply(plugin = "com.google.gms.google-services")`.
   - **iOS**: Xcode подхватит `GoogleService-Info.plist` из папки Runner; при необходимости добавь параметры в `ios/Runner/Info.plist` по документации.

3. Открой **`lib/main.dart`**. Убедись, что перед `runApp(...)` выполняется:
   ```dart
   import 'package:firebase_core/firebase_core.dart';

   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();  // читает ваши google-services.json и GoogleService-Info.plist
     // ... остальная инициализация (Sentry, AppMetrica, локаль)
     runApp(const FinControlRoot());
   }
   ```
   Если конфигов ещё нет, `Firebase.initializeApp()` выбросит исключение — сначала положи файлы из шагов 2–3, затем запускай.

4. Дальше по практикам 10–15 добавляй в `pubspec.yaml` нужные пакеты (`firebase_crashlytics`, `firebase_messaging` и т.д.) и код по шагам в каждой практике. Версии — совместимые с `firebase_core` (см. pub.dev или `flutter pub add firebase_crashlytics`).

## Проверка

- [ ] В Firebase Console в проекте отображаются приложения Android (и при необходимости iOS) с правильным package name / Bundle ID.
- [ ] Файл `android/app/google-services.json` лежит в проекте и соответствует твоему проекту Firebase.
- [ ] В `lib/main.dart` вызывается `await Firebase.initializeApp()` до `runApp(...)`.
- [ ] `flutter run` завершается без ошибки «No Firebase App '[DEFAULT]' has been created».

## Что показать на экзамене / созвоне

1. Открой Firebase Console → покажи свой проект с добавленными приложениями Android/iOS (package name совпадает).
2. Покажи файл `android/app/google-services.json` в проекте.
3. Покажи `lib/main.dart` — строку `await Firebase.initializeApp()`.
4. Запусти приложение — покажи, что стартует без ошибок Firebase.
5. Кратко скажи: «Создал проект Firebase, добавил приложение с правильным package name, скачал конфиги, инициализировал в коде — приложение подключается к Firebase.»

## Траблшутинг

- **«No Firebase App '[DEFAULT]' has been created»** — проверь, что файлы конфигов лежат в `android/app/` и `ios/Runner/` и что `Firebase.initializeApp()` вызывается до любого использования Firebase. Подробнее: [FAQ — Firebase](../FAQ.md#firebase).
- **Где взять google-services.json и куда класть:** [FAQ — Где взять google-services.json](../FAQ.md#где-взять-google-servicesjson-и-куда-его-класть).
- **Gradle sync failed после добавления google-services.json** — проверь, что в `android/build.gradle.kts` добавлен classpath `com.google.gms:google-services`, а в `android/app/build.gradle.kts` — `apply(plugin = "com.google.gms.google-services")`.
- **iOS: CocoaPods ошибка** — из корня проекта выполни `cd ios && pod install && cd ..`, затем снова `flutter run`.

**Ключи Sentry и AppMetrica** для практик 06–07 задаются не здесь, а в [STUDENT_ENV.md](../STUDENT_ENV.md) (файл `lib/config/student_env.dart`). Для Firebase используются только конфиги из этого шага.

---

## Ссылки

- [Критерии приёмки 00 — Firebase setup](../acceptance-criteria/00-firebase-setup.md)
- [Список практик и порядок](README.md#порядок-прохождения)
- [FAQ — Firebase](../FAQ.md#firebase)
