# Firebase: регистрация проекта и подключение к FinControl

Все практики по Firebase (Crashlytics, FCM, Analytics, Remote Config, Performance, In-App Messaging) требуют **вашего собственного** проекта Firebase. Ученики сами регистрируют проект и подставляют свои конфиги — так вы сможете работать с консолью и данными без доступа к чужому проекту.

## Шаг 1: Создать проект в Firebase

1. Перейдите на [console.firebase.google.com](https://console.firebase.google.com) и войдите (Google-аккаунт).
2. **Создать проект** (или **Add project**) → укажите название (например `fin-control-practice`).
3. При необходимости отключите Google Analytics для упрощения или включите — на ваше усмотрение.
4. Дождитесь создания проекта.

## Шаг 2: Добавить приложение Android

1. В обзоре проекта нажмите **Добавить приложение** → выберите **Android**.
2. Укажите **Package name** — он должен совпадать с приложением FinControl:
   - откройте `android/app/build.gradle.kts` (или `build.gradle`) и найдите `applicationId`;
   - либо посмотрите в `android/app/src/main/AndroidManifest.xml` атрибут `package`.
   - Обычно это что-то вроде `com.yourname.fincontrol.fin_control` или `com.example.fin_control`.
3. Никнейм и SHA-1 можно не заполнять для начала (для FCM и части возможностей они понадобятся позже).
4. Нажмите **Зарегистрировать приложение**.
5. **Скачайте** файл **google-services.json** и поместите его в папку **`android/app/`** проекта FinControl (рядом с `build.gradle.kts`).

## Шаг 3: Добавить приложение iOS (если нужна практика на iOS)

1. В обзоре проекта снова **Добавить приложение** → выберите **iOS**.
2. Укажите **Apple bundle ID** — он должен совпадать с Bundle Identifier в Xcode (откройте `ios/Runner.xcworkspace` → Runner → General → Bundle Identifier). Обычно что-то вроде `com.yourname.fincontrol`.
3. Никнейм и App Store ID можно не заполнять для учебного проекта.
4. **Скачайте** файл **GoogleService-Info.plist** и добавьте его в проект Xcode в папку **Runner** (перетащите в `ios/Runner/` и отметьте добавление в таргет Runner).

## Шаг 4: Добавить Firebase в проект и инициализировать

1. В `pubspec.yaml` в блок `dependencies` добавьте:
   ```yaml
   firebase_core: ^3.0.0
   ```
   Выполните `flutter pub get`.

2. Настройте платформы (один раз):
   - **Android**: в `android/build.gradle.kts` (root) добавьте класспуть `com.google.gms:google-services` и в `android/app/build.gradle.kts` в конец файла — `apply(plugin = "com.google.gms.google-services")`. Подробно см. [документацию Flutter Firebase](https://firebase.flutter.dev/docs/installation).
   - **iOS**: в `ios/Runner/Info.plist` при необходимости добавьте параметры по документации; Xcode подхватит `GoogleService-Info.plist` из папки Runner.

3. В `lib/main.dart` перед `runApp(...)` добавьте:
   ```dart
   import 'package:firebase_core/firebase_core.dart';

   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();  // использует ваши google-services.json и GoogleService-Info.plist
     // ... остальная инициализация (Sentry, AppMetrica, локаль)
     runApp(const FinControlRoot());
   }
   ```
   Если конфигов ещё нет, `Firebase.initializeApp()` выбросит исключение — сначала положите файлы из шагов 2–3, затем запускайте.

4. Дальше по практикам 10–15 добавляйте в `pubspec.yaml` только нужные пакеты (firebase_crashlytics, firebase_messaging и т.д.) и код по шагам в каждой практике. Версии подбирайте совместимые с `firebase_core: ^3.0.0` (смотрите pub.dev или `flutter pub add firebase_crashlytics` и т.д.).

## Кратко

- **Вы** создаёте проект в Firebase.
- **Вы** добавляете приложение Android (и при необходимости iOS) и скачиваете **свои** `google-services.json` и `GoogleService-Info.plist`.
- **Вы** кладёте эти файлы в проект FinControl и один раз вызываете `Firebase.initializeApp()` в `main.dart`.
- Дальше работаете с модулями Firebase по практикам 10–15.
