# Практика: Android — сборка и публикация в дистрибьютор

**Одно приложение** FinControl. Задача: собрать release-сборку (AAB/APK), подписать keystore и распространить через **Google Play (Internal testing)** или **Firebase App Distribution** — тестер устанавливает по ссылке.

## Цель

Собрать release-сборку приложения FinControl для Android, подписать её (keystore) и распространить через **Google Play (Internal testing)** или **Firebase App Distribution** так, чтобы тестер мог установить приложение по ссылке.

## Ожидаемый результат

- Настроена подпись release (keystore, `key.properties`, `signingConfigs` в `build.gradle.kts`).
- Собран AAB (`flutter build appbundle --release`) или APK (`flutter build apk --release`); артефакт подписан.
- AAB загружен в Google Play Console → Internal testing (или APK в Firebase App Distribution); тестер получает ссылку и может установить приложение на устройство.

---

## Что понадобится

- Релизный keystore для подписи (или создать новый)
- Аккаунт Google Play Developer (разовый взнос) или Firebase
- Проект FinControl с настроенным `android/app/build.gradle.kts`

## Шаг 1: Настройка подписи (signing config)

1. Создай keystore (если ещё нет):
   ```bash
   keytool -genkey -v -keystore fincontrol-release.keystore -alias fincontrol -keyalg RSA -keysize 2048 -validity 10000
   ```
   Сохрани пароли и алиас в надёжном месте.

2. В `android/` создай файл `key.properties` (не коммить в git!):
   ```properties
   storePassword=ваш_пароль
   keyPassword=ваш_пароль
   keyAlias=fincontrol
   storeFile=../fincontrol-release.keystore
   ```

3. В `android/app/build.gradle.kts` добавь чтение `key.properties` и блок `signingConfigs` + использование в `buildTypes.release`:
   ```kotlin
   val keystorePropertiesFile = rootProject.file("key.properties")
   val keystoreProperties = java.util.Properties()
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(keystorePropertiesFile.inputStream())
   }
   android {
       ...
       signingConfigs {
           create("release") {
               keyAlias = keystoreProperties["keyAlias"] as String?
               keyPassword = keystoreProperties["keyPassword"] as String?
               storeFile = keystoreProperties["storeFile"]?.let { rootProject.file(it) }
               storePassword = keystoreProperties["storePassword"] as String?
           }
       }
       buildTypes {
           release {
               signingConfig = signingConfigs.getByName("release")
               ...
           }
       }
   }
   ```

## Шаг 2: Сборка AAB (рекомендуется для Google Play) или APK

Из корня проекта:

```bash
flutter build appbundle --release
```

Результат: `build/app/outputs/bundle/release/app-release.aab`

Для APK (например для Firebase App Distribution или прямого распространения):

```bash
flutter build apk --release
```

Результат: `build/app/outputs/flutter-apk/app-release.apk`

## Шаг 3a: Загрузка в Google Play (Internal testing)

1. Зайди в [Google Play Console](https://play.google.com/console).
2. Создай приложение (если ещё нет), укажи название FinControl.
3. **Release** → **Testing** → **Internal testing** → **Create new release**.
4. Загрузи `app-release.aab`.
5. Укажи описание релиза и сохрани. После проверки добавь тестеров по email (список в Internal testing). Тестеры получат ссылку на установку через Play Console.

## Шаг 3b: Загрузка в Firebase App Distribution

1. В [Firebase Console](https://console.firebase.google.com) открой проект → **App Distribution**.
2. Подключи Android-приложение (если ещё не подключено), укажи package name из `android/app/build.gradle.kts`/манифеста.
3. **Distribute** → загрузи `app-release.apk` (или AAB, если поддерживается).
4. Добавь тестеров по email или группу. Тестеры получат письмо со ссылкой на скачивание и установку.

## Проверка

- [ ] Release-сборка собирается без ошибок (`flutter build appbundle --release` или `flutter build apk --release`), артефакт подписан.
- [ ] AAB загружен в Google Play Console → Internal testing (или APK в Firebase App Distribution).
- [ ] Тестер может установить приложение по ссылке из консоли и запустить его на устройстве.

## Траблшутинг

- **Keystore not found** — проверь путь в `key.properties` (относительно папки `android/`); файл `key.properties` не коммить в репозиторий.
- **Google Play не принимает AAB** — убедись, что `versionCode` в `android/app/build.gradle.kts` выше ранее загруженной версии.

## Что показать на экзамене / созвоне

1. Покажи подписанную release-сборку: `flutter build apk --release` завершается без ошибок.
2. Покажи Google Play Console → Internal testing (или Firebase App Distribution) с загруженной сборкой.
3. Покажи, что тестер может установить приложение по ссылке.
4. Запусти установленное приложение — покажи, что оно работает.
5. Кратко скажи: «Настроил keystore, подписал release-сборку, загрузил в дистрибьютор — тестер может установить по ссылке.»

## Дополнительно: полезные детали

### AAB vs APK
- **AAB** (Android App Bundle) — рекомендуется для Google Play. Google Play сам генерирует оптимизированные APK для каждого устройства (меньший размер).
- **APK** — универсальный файл, подходит для Firebase App Distribution, прямой установки и тестирования.

### SHA-1 для Firebase
Если используешь Firebase (практики 10–15), добавь SHA-1 отпечаток в Firebase Console:

```bash
keytool -list -v -keystore fincontrol-release.keystore -alias fincontrol
```

Скопируй SHA-1 → Firebase Console → Project Settings → Your apps → Add fingerprint.

Для debug-ключа:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
```

### Firebase App Distribution — подробнее

1. Установи CLI: `npm install -g firebase-tools` и `firebase login`.
2. Загрузи APK через CLI:
   ```bash
   firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
     --app YOUR_FIREBASE_APP_ID \
     --groups "testers" \
     --release-notes "Версия 1.0 — первый релиз для тестирования"
   ```
3. Тестеры получат email со ссылкой и инструкцией по установке.

### Версионирование
В `pubspec.yaml`: `version: 1.0.0+1` — формат `major.minor.patch+buildNumber`.
- Каждая загрузка в Google Play требует увеличения `buildNumber`.
- Увеличивай `buildNumber` при каждой сборке: `+1` → `+2` → `+3`.

## Ссылки

- [Критерии приёмки 09 — Android-дистрибуция](../acceptance-criteria/09-android-distribution.md)
- [FAQ — Как собрать APK](../FAQ.md#как-собрать-apk-для-установки-на-телефон-или-для-сдачи)
- [Список практик](README.md)
