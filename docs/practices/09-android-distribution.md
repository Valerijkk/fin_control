# Практика: Android — сборка и публикация в дистрибьютор

## Цель

Собрать release-сборку Android-приложения FinControl, подписать её и распространить через популярный дистрибьютор: **Google Play (Internal testing)** или **Firebase App Distribution**.

## Что понадобится

- Релизный keystore для подписи (или создать новый)
- Аккаунт Google Play Developer (разовый взнос) или Firebase
- Проект FinControl с настроенным `android/app/build.gradle.kts`

## Шаг 1: Настройка подписи (signing config)

1. Создайте keystore (если ещё нет):
   ```bash
   keytool -genkey -v -keystore fincontrol-release.keystore -alias fincontrol -keyalg RSA -keysize 2048 -validity 10000
   ```
   Сохраните пароли и алиас в надёжном месте.

2. В `android/` создайте файл `key.properties` (не коммитьте в git!):
   ```properties
   storePassword=ваш_пароль
   keyPassword=ваш_пароль
   keyAlias=fincontrol
   storeFile=../fincontrol-release.keystore
   ```

3. В `android/app/build.gradle.kts` добавьте чтение `key.properties` и блок `signingConfigs` + использование в `buildTypes.release`:
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

1. Зайдите в [Google Play Console](https://play.google.com/console).
2. Создайте приложение (если ещё нет), укажите название FinControl.
3. **Release** → **Testing** → **Internal testing** → **Create new release**.
4. Загрузите `app-release.aab`.
5. Укажите описание релиза и сохраните. После проверки добавьте тестеров по email (список в Internal testing). Тестеры получат ссылку на установку через Play Console.

## Шаг 3b: Загрузка в Firebase App Distribution

1. В [Firebase Console](https://console.firebase.google.com) откройте проект → **App Distribution**.
2. Подключите Android-приложение (если ещё не подключено), укажите package name из `android/app/build.gradle.kts`/манифеста.
3. **Distribute** → загрузите `app-release.apk` (или AAB, если поддерживается).
4. Добавьте тестеров по email или группу. Тестеры получат письмо со ссылкой на скачивание и установку.

## Что проверить

- [ ] Release-сборка собирается без ошибок, подписана.
- [ ] AAB загружен в Google Play или APK в Firebase App Distribution.
- [ ] Тестер может установить приложение по ссылке и запустить его.

## Устранение неполадок

- **Keystore not found**: проверьте путь в `key.properties` (относительно папки `android/`).
- **Google Play не принимает AAB**: убедитесь, что версия `versionCode` в `android/app/build.gradle.kts` выше предыдущей загруженной.
