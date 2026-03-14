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

## Ссылки

- [Критерии приёмки 09 — Android-дистрибуция](../acceptance-criteria/09-android-distribution.md)
- [FAQ — Как собрать APK](../FAQ.md#как-собрать-apk-для-установки-на-телефон-или-для-сдачи)
- [Список практик](README.md)
