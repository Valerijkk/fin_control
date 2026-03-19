# 🤖 Практика 09: Android — сборка и публикация в дистрибьютор

> Собираем release-сборку FinControl для Android (AAB/APK), подписываем keystore и распространяем через Google Play (Internal testing) или Firebase App Distribution. Результат — тестер устанавливает приложение на устройство по ссылке.

---

## 🎯 Цель

Собрать подписанную release-сборку приложения FinControl для Android и распространить её через **Google Play Console (Internal testing)** или **Firebase App Distribution** так, чтобы тестер мог установить приложение на устройство по ссылке-приглашению.

---

## ✅ Ожидаемый результат

- ✔️ Настроена подпись release-сборки (keystore, `key.properties`, `signingConfigs` в `build.gradle.kts`)
- ✔️ Собран **AAB** (`flutter build appbundle --release`) или **APK** (`flutter build apk --release`); артефакт подписан
- ✔️ Сборка загружена в **Google Play Console → Internal testing** или **Firebase App Distribution**
- ✔️ Тестер получил ссылку и может установить приложение на устройство

---

## 📋 Что понадобится

| Что | Зачем |
|-----|-------|
| **JDK** (Java Development Kit) | Утилита `keytool` для создания keystore |
| **Аккаунт Google Play Developer** ($25 разово) **или** Firebase-проект | Загрузка и распространение сборки |
| Проект FinControl с настроенным `android/app/build.gradle.kts` | Исходный код для сборки |
| Android-устройство у тестера | Установка по ссылке |

---

## 📝 Пошаговая инструкция

### Шаг 1: Создание keystore для подписи

1. Открой терминал и выполни команду для создания keystore:
   ```bash
   keytool -genkey -v -keystore fincontrol-release.keystore -alias fincontrol -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Ответь на вопросы (имя, организация, город и т.д.) — для учебного проекта можно заполнить произвольно.
3. Введи и запомни **пароль keystore** и **пароль ключа** (могут совпадать).
4. Файл `fincontrol-release.keystore` появится в текущей папке. Положи его в корень проекта (рядом с `android/`).

> ⚠️ **Важно:** запиши пароли и алиас в надёжном месте. Без них ты не сможешь обновить приложение в Google Play. Keystore нельзя восстановить!

---

### Шаг 2: Настройка signing config в проекте

1. Создай файл **`android/key.properties`** со следующим содержимым:
   ```properties
   storePassword=твой_пароль
   keyPassword=твой_пароль
   keyAlias=fincontrol
   storeFile=../fincontrol-release.keystore
   ```

> ⚠️ **Не коммить `key.properties` в git!** Добавь его в `.gitignore`, если он ещё не добавлен.

2. Открой файл **`android/app/build.gradle.kts`** и добавь чтение `key.properties` и блок `signingConfigs`:

   ```kotlin
   // В начале файла, до блока android {}
   val keystorePropertiesFile = rootProject.file("key.properties")
   val keystoreProperties = java.util.Properties()
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(keystorePropertiesFile.inputStream())
   }

   android {
       // ... существующие настройки ...

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
               // ... остальные настройки release ...
           }
       }
   }
   ```

3. Сохрани файл.

---

### Шаг 3: Сборка release-артефакта

**AAB (рекомендуется для Google Play):**

```bash
flutter build appbundle --release
```

Результат: `build/app/outputs/bundle/release/app-release.aab`

**APK (для Firebase App Distribution или прямой установки):**

```bash
flutter build apk --release
```

Результат: `build/app/outputs/flutter-apk/app-release.apk`

> 💡 **AAB vs APK:** AAB — формат для Google Play, который сам генерирует оптимизированные APK для каждого устройства (меньший размер). APK — универсальный файл для прямой установки и Firebase App Distribution.

---

### Шаг 4a: Загрузка в Google Play Console (Internal testing)

1. Открой [Google Play Console](https://play.google.com/console) и войди.
2. Создай приложение (если ещё нет): **Create app** → укажи название **FinControl**, язык, тип (App), бесплатное/платное.
3. Перейди в **Release → Testing → Internal testing**.
4. Нажми **Create new release**.
5. Загрузи файл **`app-release.aab`**.
6. Укажи описание релиза (например: «Первая тестовая сборка FinControl»).
7. Нажми **Save** → **Review release** → **Start rollout to Internal testing**.
8. Перейди в раздел **Testers** → добавь email-адреса тестеров.
9. Скопируй **ссылку для тестеров** — отправь её тестерам. Они смогут установить приложение через Google Play.

> 📌 При первой загрузке Google Play потребует заполнить информацию о приложении (описание, скриншоты, политика конфиденциальности). Для Internal testing можно заполнить минимально.

---

### Шаг 4b: Загрузка в Firebase App Distribution (альтернатива)

**Через веб-интерфейс:**

1. Открой [Firebase Console](https://console.firebase.google.com) → твой проект → **App Distribution**.
2. Подключи Android-приложение (если ещё не подключено), укажи **package name** из манифеста.
3. Нажми **Distribute** → загрузи файл **`app-release.apk`**.
4. Добавь тестеров по email или выбери группу.
5. Тестеры получат письмо со ссылкой на скачивание и инструкцией по установке.

**Через CLI (для продвинутых):**

```bash
# Установка Firebase CLI
npm install -g firebase-tools
firebase login

# Загрузка APK
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups "testers" \
  --release-notes "Версия 1.0 — первый релиз для тестирования"
```

Тестеры получат email со ссылкой и инструкцией по установке.

---

## 🔍 Проверка

- [ ] Release-сборка собирается без ошибок (`flutter build appbundle --release` или `flutter build apk --release`), артефакт подписан
- [ ] Файл `key.properties` создан, keystore на месте, пароли записаны
- [ ] AAB загружен в **Google Play Console → Internal testing** (или APK в **Firebase App Distribution**)
- [ ] Тестер может установить приложение по ссылке из консоли и запустить его на устройстве

---

## 🎓 Что показать на экзамене

1. Показать успешную сборку: `flutter build apk --release` завершается без ошибок
2. Показать **Google Play Console → Internal testing** (или **Firebase App Distribution**) с загруженной сборкой
3. Показать, что тестер получил ссылку и может установить приложение
4. Запустить установленное приложение на устройстве — показать, что оно работает
5. Кратко сказать: *«Настроил keystore, подписал release-сборку, загрузил в дистрибьютор — тестер может установить по ссылке»*

---

## 🛠 Траблшутинг

**Keystore not found**
→ Проверь путь в `key.properties` — он указан **относительно папки `android/`**. Если keystore лежит в корне проекта, путь будет `../fincontrol-release.keystore`.

**Google Play не принимает AAB**
→ Убедись, что `versionCode` в `android/app/build.gradle.kts` (или `version` в `pubspec.yaml`) **выше** ранее загруженной версии. Каждая загрузка требует увеличения build number.

**Ошибка "Keystore was tampered with"**
→ Неверный пароль keystore. Проверь пароль в `key.properties`.

**APK не устанавливается на устройстве тестера**
→ Тестер должен разрешить установку из неизвестных источников: **Настройки → Безопасность → Неизвестные источники** (или для конкретного приложения в Android 8+).

**flutter build завершается с ошибкой Gradle**
→ Проверь, что `key.properties` находится в папке `android/` (не в корне проекта). Убедись, что `build.gradle.kts` корректно читает файл.

---

## 🔗 Ссылки

- [Критерии приёмки 09 — Android-дистрибуция](../acceptance-criteria/09-android-distribution.md)
- [FAQ — Как собрать APK](../FAQ.md#как-собрать-apk-для-установки-на-телефон-или-для-сдачи)
- [Список практик](README.md)

---

## 📚 Дополнительно: полезные детали

### AAB vs APK — когда что использовать

| Параметр | AAB | APK |
|----------|-----|-----|
| **Для чего** | Google Play | Firebase App Distribution, прямая установка, тестирование |
| **Оптимизация** | Google Play генерирует оптимизированные APK для каждого устройства | Один файл для всех устройств |
| **Размер** | Меньше для конечного пользователя | Больше (содержит ресурсы для всех устройств) |
| **Команда сборки** | `flutter build appbundle --release` | `flutter build apk --release` |

---

### SHA-1 для Firebase

Если используешь Firebase (практики 10–15), добавь SHA-1 отпечаток в Firebase Console:

```bash
# Для release-ключа
keytool -list -v -keystore fincontrol-release.keystore -alias fincontrol

# Для debug-ключа
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
```

Скопируй SHA-1 → Firebase Console → **Project Settings → Your apps → Add fingerprint**.

---

### Версионирование

В `pubspec.yaml` версия задаётся в формате `major.minor.patch+buildNumber`:

```yaml
version: 1.0.0+1
```

- **`1.0.0`** — версия, видимая пользователю (versionName)
- **`+1`** — номер сборки (versionCode) — **должен увеличиваться** при каждой загрузке в Google Play
- Пример: `1.0.0+1` → `1.0.0+2` → `1.0.1+3` → `1.1.0+4`

> 📌 Google Play отклонит загрузку, если `versionCode` не больше предыдущей загруженной версии.
