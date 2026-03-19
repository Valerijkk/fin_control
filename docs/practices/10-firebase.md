# 🔥 Практика 10: Firebase — полный гайд по всем модулям

> Единый документ по всем Firebase-модулям для FinControl: настройка проекта, Crashlytics, Cloud Messaging, Analytics, Remote Config, Performance Monitoring и In-App Messaging. Каждая часть — самостоятельный блок с пошаговой инструкцией, проверкой и сценариями.

---

## 📋 Оглавление

- [Часть 0: Настройка проекта Firebase](#часть-0-настройка-проекта-firebase)
- [Часть 1: Crashlytics — стабильность релиза](#часть-1-crashlytics--стабильность-релиза)
- [Часть 2: Cloud Messaging (FCM) — push-уведомления](#часть-2-cloud-messaging-fcm--push-уведомления)
- [Часть 3: Analytics — события и воронки](#часть-3-analytics--события-и-воронки)
- [Часть 4: Remote Config — управление без релиза](#часть-4-remote-config--управление-без-релиза)
- [Часть 5: Performance Monitoring — скорость и регрессии](#часть-5-performance-monitoring--скорость-и-регрессии)
- [Часть 6: In-App Messaging — кампании внутри приложения](#часть-6-in-app-messaging--кампании-внутри-приложения)
- [Общие ссылки](#общие-ссылки)

---

## Часть 0: Настройка проекта Firebase

> **Что делаем:** создаём свой проект в Firebase Console, добавляем приложение FinControl (Android / iOS), скачиваем конфиги и подключаем Firebase в коде.
> **Зачем:** без этого шага части 1–6 (Crashlytics, FCM, Analytics, Remote Config, Performance, In-App Messaging) не заработают.
> **Результат:** приложение стартует с `Firebase.initializeApp()` без ошибок, и твоя Firebase Console видит подключённое приложение.

---

### 🎯 Цель

Зарегистрировать свой проект в Firebase Console, добавить в него приложение FinControl (Android и при необходимости iOS), скачать конфигурационные файлы, положить их в проект и инициализировать Firebase в коде — чтобы части 1–6 работали с **твоей** консолью.

> 📌 **Ключи Sentry и AppMetrica** для практик 06–07 задаются не здесь, а в [STUDENT_ENV.md](../STUDENT_ENV.md) → `lib/config/student_env.dart`. Для Firebase используются только конфиги из этой инструкции.

---

### ✅ Ожидаемый результат

- ✔️ В [Firebase Console](https://console.firebase.google.com) есть твой проект с зарегистрированными приложениями Android и/или iOS (package name / Bundle ID совпадают с FinControl)
- ✔️ В проекте лежат **твои** файлы: `android/app/google-services.json` и при необходимости `ios/Runner/GoogleService-Info.plist`
- ✔️ В `lib/main.dart` перед `runApp(...)` вызывается `Firebase.initializeApp()`
- ✔️ Приложение запускается без ошибки *«No Firebase App '[DEFAULT]' has been created»*

---

### 📋 Что понадобится

| Инструмент / ресурс | Зачем | Где взять |
|---------------------|-------|-----------|
| **Google-аккаунт** | Авторизация в Firebase Console | [accounts.google.com](https://accounts.google.com) |
| **Firebase Console** | Создание проекта и получение конфигов | [console.firebase.google.com](https://console.firebase.google.com) |
| **Рабочий проект FinControl** | Должен запускаться через `flutter run` | [00-getting-started.md](00-getting-started.md) |
| **Android Studio / VS Code** | Редактирование файлов проекта | Уже установлено из предыдущего шага |

> ⚠️ Перед этой практикой обязательно выполни [00-getting-started.md](00-getting-started.md) — проект должен клонироваться и запускаться.

---

### 📝 Пошаговая инструкция

#### Шаг 0.1: Создай проект в Firebase Console

1. Открой в браузере [console.firebase.google.com](https://console.firebase.google.com) и войди через Google-аккаунт
2. Нажми кнопку **«Создать проект»** (или **«Add project»**, если интерфейс на английском)
3. Укажи название проекта — например, `fin-control-practice`

   > 💡 Название может быть любым — оно видно только тебе в консоли. Но лучше выбрать осмысленное, чтобы не запутаться.

4. На шаге Google Analytics — включи или отключи на своё усмотрение (для учебных практик это не критично; для части 3 — Firebase Analytics — лучше включить)
5. Нажми **«Создать проект»** и дождись завершения. Ты окажешься в **обзоре проекта** (Project Overview)

---

#### Шаг 0.2: Добавь приложение Android

1. В обзоре проекта нажми **«Добавить приложение»** → выбери иконку **Android** (робот)
2. В поле **Android package name** укажи идентификатор приложения FinControl. Чтобы его найти:
   - Открой файл **`android/app/build.gradle.kts`** в проекте
   - Найди строку `applicationId = "..."`
   - Скопируй значение в кавычках (например `com.yourname.fincontrol.fin_control`) и вставь в форму Firebase

   > ⚠️ Package name должен **точно совпадать** с `applicationId` в проекте. Если будет расхождение — Firebase не подключится.

3. Поля **App nickname** и **Debug signing certificate SHA-1** можно пока не заполнять (SHA-1 понадобится для практик FCM и подписки)
4. Нажми **«Зарегистрировать приложение»** (Register app)
5. На следующей странице нажми **«Скачать google-services.json»** — файл скачается на компьютер
6. Перемести скачанный файл в папку **`android/app/`** проекта FinControl (рядом с `build.gradle.kts`):

   ```bash
   # Пример для Windows (PowerShell)
   Move-Item ~/Downloads/google-services.json ./android/app/google-services.json

   # Пример для Mac / Linux
   mv ~/Downloads/google-services.json ./android/app/google-services.json
   ```

7. Нажми **«Далее»** → **«Далее»** → **«Перейти в консоль»** (остальные шаги Firebase мастера мы выполним вручную ниже)

> ⚠️ **Безопасность:** файлы `google-services.json` и `GoogleService-Info.plist` содержат идентификаторы и ключи проекта. В учебном проекте их можно держать локально, но **не коммить в публичный репозиторий**. В реальных проектах добавь их в `.gitignore` и доставляй через CI. Подробнее: [STUDENT_ENV.md](../STUDENT_ENV.md) (раздел «Безопасность ключей»).

---

#### Шаг 0.3: Добавь приложение iOS (если нужна практика на iOS)

> 💡 Этот шаг нужен только если ты планируешь запускать FinControl на iOS-симуляторе или устройстве. Если работаешь только на Android — переходи к Шагу 0.4.

1. В обзоре проекта снова нажми **«Добавить приложение»** → выбери **iOS** (яблоко)
2. Укажи **Apple bundle ID** — он должен совпадать с Bundle Identifier в Xcode:
   - Открой `ios/Runner.xcworkspace` в Xcode
   - Выбери **Runner** в дереве проекта → вкладка **General** → поле **Bundle Identifier**
   - Скопируй значение (обычно вида `com.yourname.fincontrol`) и вставь в форму Firebase
3. Поля **App nickname** и **App Store ID** можно не заполнять для учебного проекта
4. Нажми **«Зарегистрировать приложение»**
5. **Скачай** файл **`GoogleService-Info.plist`**
6. Добавь его в проект Xcode:
   - Перетащи файл в папку **`ios/Runner/`** в Xcode
   - В диалоге отметь галочку **«Add to target: Runner»**
   - Убедись, что файл появился в `ios/Runner/GoogleService-Info.plist`

---

#### Шаг 0.4: Настрой Firebase в проекте и инициализируй

##### 0.4.1. Добавь зависимость `firebase_core`

1. Открой файл **`pubspec.yaml`** в корне проекта
2. В блок `dependencies` добавь (если ещё нет):
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     firebase_core: ^3.0.0   # <-- добавь эту строку
   ```
3. В терминале из корня проекта выполни:
   ```bash
   flutter pub get
   ```

##### 0.4.2. Настрой Android (Gradle)

1. Открой файл **`android/build.gradle.kts`** (корневой, не тот что в `app/`). Убедись, что в блоке `buildscript → dependencies` есть:
   ```kotlin
   buildscript {
       dependencies {
           // ... другие зависимости
           classpath("com.google.gms:google-services:4.4.2") // <-- добавь если нет
       }
   }
   ```

2. Открой файл **`android/app/build.gradle.kts`**. В конец файла добавь (если нет):
   ```kotlin
   apply(plugin = "com.google.gms.google-services")
   ```

> 💡 Версию `google-services` можно уточнить на [Maven Repository](https://mvnrepository.com/artifact/com.google.gms/google-services). На момент написания актуальна `4.4.2`.

##### 0.4.3. Настрой iOS (если используешь)

1. Xcode автоматически подхватит `GoogleService-Info.plist` из папки `Runner`
2. При необходимости добавь параметры в `ios/Runner/Info.plist` по [официальной документации Flutter Firebase](https://firebase.flutter.dev/docs/installation)
3. Выполни установку CocoaPods:
   ```bash
   cd ios && pod install && cd ..
   ```

##### 0.4.4. Инициализируй Firebase в коде

1. Открой **`lib/main.dart`**
2. Убедись, что перед `runApp(...)` выполняется инициализация:

   ```dart
   import 'package:firebase_core/firebase_core.dart';

   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();

     // Инициализация Firebase — читает google-services.json / GoogleService-Info.plist
     await Firebase.initializeApp();

     // ... остальная инициализация (Sentry, AppMetrica, локаль и т.д.)
     runApp(const FinControlRoot());
   }
   ```

> ⚠️ Если конфигов ещё нет в проекте, `Firebase.initializeApp()` выбросит исключение. Сначала положи файлы из Шагов 0.2–0.3, затем запускай.

##### 0.4.5. Запусти и проверь

1. Выполни:
   ```bash
   flutter run
   ```
2. Приложение должно запуститься **без ошибки** *«No Firebase App '[DEFAULT]' has been created»*
3. В логах (`flutter run` или Logcat) не должно быть Firebase-ошибок

> 💡 Дальше по частям 1–6 ты будешь добавлять в `pubspec.yaml` нужные пакеты (`firebase_crashlytics`, `firebase_messaging`, `firebase_analytics` и т.д.) и код по шагам каждой части. Версии должны быть совместимы с `firebase_core` — проверяй на [pub.dev](https://pub.dev/) или используй `flutter pub add firebase_crashlytics`.

---

### 🔍 Проверка (Часть 0)

- [ ] В Firebase Console в проекте отображаются приложения Android (и при необходимости iOS) с правильным package name / Bundle ID
- [ ] Файл `android/app/google-services.json` лежит в проекте и соответствует **твоему** проекту Firebase
- [ ] Если используешь iOS — файл `ios/Runner/GoogleService-Info.plist` тоже на месте
- [ ] В `lib/main.dart` вызывается `await Firebase.initializeApp()` до `runApp(...)`
- [ ] `flutter run` завершается без ошибки *«No Firebase App '[DEFAULT]' has been created»*
- [ ] Приложение запускается и работает как обычно (приветственный экран → главный экран)

---

### 🎓 Что показать на экзамене (Часть 0)

1. **Firebase Console:** открой в браузере → покажи свой проект с добавленными приложениями Android/iOS (package name совпадает с `applicationId` в проекте)
2. **Конфиг в проекте:** покажи файл `android/app/google-services.json` — он лежит на месте
3. **Код инициализации:** покажи `lib/main.dart` — строку `await Firebase.initializeApp()`
4. **Запуск:** запусти приложение — покажи, что стартует без ошибок Firebase
5. **Резюме:** кратко скажи: *«Создал проект Firebase, добавил приложение с правильным package name, скачал конфиги, инициализировал в коде — приложение подключается к Firebase»*

---

### 🛠 Траблшутинг (Часть 0)

| Проблема | Решение |
|---------|---------|
| **«No Firebase App '[DEFAULT]' has been created»** | Проверь, что файлы конфигов лежат в `android/app/` и `ios/Runner/`, и что `Firebase.initializeApp()` вызывается **до** любого использования Firebase. Подробнее: [FAQ — Firebase](../FAQ.md#firebase) |
| **Не знаю где взять `google-services.json`** | Firebase Console → твой проект → ⚙️ Project Settings → вкладка **General** → секция «Your apps» → кнопка **«Download google-services.json»**. Подробнее: [FAQ](../FAQ.md#где-взять-google-servicesjson-и-куда-его-класть) |
| **Gradle sync failed после добавления конфига** | Проверь, что в `android/build.gradle.kts` добавлен `classpath("com.google.gms:google-services:...")`, а в `android/app/build.gradle.kts` — `apply(plugin = "com.google.gms.google-services")` |
| **Package name не совпадает** | Открой `android/app/build.gradle.kts`, найди `applicationId` — именно это значение должно быть указано в Firebase Console. Если расходится — удали приложение в Firebase и создай заново с правильным package name |
| **iOS: CocoaPods ошибка** | Из корня проекта выполни `cd ios && pod install && cd ..`, затем снова `flutter run` |
| **iOS: `GoogleService-Info.plist` не найден** | Убедись, что файл добавлен в Xcode в таргет **Runner** (правый клик → Add Files to «Runner» → отметь «Add to target: Runner») |

> 📌 Полный список проблем и решений — в [FAQ](../FAQ.md#firebase).

---

### 🧪 Практические сценарии (Часть 0)

#### Сценарий 0.1: Проверка подключения к Firebase

1. Запусти приложение через `flutter run`
2. Открой Firebase Console → **Project Overview**
3. Убедись, что в разделе приложений отображается статус — Firebase видит твоё приложение
4. Если включил Google Analytics — перейди в **Analytics → Dashboard** и через несколько минут увидишь данные о первом запуске

#### Сценарий 0.2: Проверка через логи

1. Запусти приложение и открой **Logcat** в Android Studio (или вывод `flutter run` в терминале)
2. Поищи строки, содержащие `FirebaseApp` — должно быть сообщение об успешной инициализации
3. Не должно быть ошибок вида `FirebaseException` или `PlatformException` связанных с Firebase

---

## Часть 1: Crashlytics — стабильность релиза

> Подключаем Firebase Crashlytics к FinControl, чтобы автоматически ловить краши и нефатальные ошибки. Результат — отчёты в Firebase Console с полным контекстом: стек-трейс, устройство, версия ОС и метрика Crash-Free Users.

---

### 🎯 Цель

Подключить **Firebase Crashlytics** к приложению FinControl (твой проект Firebase), настроить перехват Flutter-ошибок и `runZonedGuarded`, вызвать тестовый краш и записать нефатальную ошибку — убедиться, что отчёты появляются в **Firebase Console → Crashlytics → Issues** с полным стек-трейсом и контекстом.

---

### ✅ Ожидаемый результат

- ✅ Crashlytics подключён в коде — перехватываются и фатальные, и нефатальные ошибки
- ✅ Тестовый краш (`FirebaseCrashlytics.instance.crash()`) отправляет отчёт после перезапуска приложения
- ✅ Нефатальная ошибка (`recordError`) видна в Firebase Console как **Non-fatal**
- ✅ В отчёте доступны: стек-трейс, устройство, версия ОС, кастомные ключи, количество затронутых пользователей
- ✅ Метрика **Crash-Free Users** отображается на Dashboard

---

### 📋 Что понадобится

| Что | Зачем |
|-----|-------|
| Выполненная [Часть 0](#часть-0-настройка-проекта-firebase) | Свой проект Firebase, конфиги в проекте, `Firebase.initializeApp()` в коде |
| Пакет `firebase_crashlytics` в `pubspec.yaml` | SDK для отправки крашей |
| Реальное устройство или эмулятор | Для генерации тестового краша |
| Доступ к [Firebase Console](https://console.firebase.google.com) | Для просмотра отчётов |

> ⚠️ **Обязательно сначала выполни [Часть 0](#часть-0-настройка-проекта-firebase):** зарегистрируй свой проект в Firebase Console, добавь приложение FinControl (Android/iOS), скачай и положи в проект **свои** `google-services.json` и `GoogleService-Info.plist`, вызови `Firebase.initializeApp()`. Без этого Crashlytics не заработает.

> 📌 Конфиги Firebase — **не** в `student_env.dart`. Ключи Sentry/AppMetrica (практики 06–07) задаются в [STUDENT_ENV.md](../STUDENT_ENV.md), а Firebase-конфиги — в файлах платформ.

---

### 📝 Пошаговая инструкция

#### Шаг 1.1: Добавление зависимости

1. Открой файл `pubspec.yaml` в корне проекта.
2. Убедись, что `firebase_core` уже добавлен (по [Части 0](#часть-0-настройка-проекта-firebase)).
3. Добавь зависимость `firebase_crashlytics`:
   ```yaml
   dependencies:
     firebase_core: ^3.0.0
     firebase_crashlytics: ^4.0.0
   ```
   > 💡 Актуальную версию смотри на [pub.dev/packages/firebase_crashlytics](https://pub.dev/packages/firebase_crashlytics) — она должна быть совместима с твоей версией `firebase_core`.

4. Выполни установку:
   ```bash
   flutter pub get
   ```

#### Шаг 1.2: Настройка перехвата ошибок в main.dart

1. Убедись, что в `lib/main.dart` уже вызывается `Firebase.initializeApp()` (по [Части 0](#часть-0-настройка-проекта-firebase)).
2. Добавь импорт и настрой перехват ошибок:

   ```dart
   import 'dart:async';
   import 'package:firebase_crashlytics/firebase_crashlytics.dart';

   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();

     // Перехват ошибок Flutter-фреймворка (например, ошибки рендеринга)
     FlutterError.onError = (details) {
       FirebaseCrashlytics.instance.recordFlutterFatalError(details);
     };

     // Перехват всех остальных ошибок (async, isolates и т.д.)
     runZonedGuarded<Future<void>>(() async {
       runApp(const FinControlRoot());
     }, (error, stack) {
       FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
     });
   }
   ```

> 📌 **Два уровня перехвата:**
> - `FlutterError.onError` — ловит ошибки внутри Flutter-фреймворка (виджеты, layout, рендеринг)
> - `runZonedGuarded` — ловит все остальные необработанные исключения (асинхронные ошибки, ошибки сети и т.д.)

#### Шаг 1.3: Тестовый краш

1. Добавь в экран Настроек (или на отдельную debug-кнопку) вызов принудительного краша:

   ```dart
   // Кнопка для тестирования Crashlytics
   ElevatedButton(
     onPressed: () {
       FirebaseCrashlytics.instance.crash();
     },
     child: const Text('Тест Crashlytics (краш)'),
   ),
   ```

2. Нажми кнопку — **приложение упадёт**. Это ожидаемое поведение.
3. **Перезапусти приложение** — Crashlytics отправляет отчёт о фатальном краше именно при следующем запуске.

> ⚠️ **Важно:** отчёт о фатальном краше отправляется **не в момент падения**, а при следующем запуске приложения. Поэтому после краша обязательно перезапусти приложение и подожди 1–2 минуты.

#### Шаг 1.4: Нефатальные ошибки

1. Для логирования ошибок, которые **не приводят к падению** (например, ошибка сети, таймаут, невалидные данные), используй `recordError`:

   ```dart
   try {
     // Какая-то операция, которая может упасть
     await loadExchangeRates();
   } catch (error, stackTrace) {
     // Записываем ошибку в Crashlytics, но приложение не падает
     FirebaseCrashlytics.instance.recordError(
       error,
       stackTrace,
       reason: 'Ошибка загрузки курсов валют',
       fatal: false,
     );
   }
   ```

2. Для добавления контекста перед потенциально опасной операцией используй **кастомные ключи**:

   ```dart
   // Устанавливаем контекст — эти ключи будут видны в отчёте
   FirebaseCrashlytics.instance.setCustomKey('screen', 'exchange');
   FirebaseCrashlytics.instance.setCustomKey('action', 'load_rates');
   FirebaseCrashlytics.instance.setCustomKey('currency_pair', 'RUB/USD');

   // Теперь если произойдёт ошибка, в отчёте будет понятно где и что делал пользователь
   ```

#### Шаг 1.5: Просмотр отчётов в Firebase Console

1. Открой [Firebase Console](https://console.firebase.google.com) → твой проект.
2. В левом меню выбери **Crashlytics**.
3. После первого краша (и перезапуска приложения) или записи нефатальной ошибки отчёт появится в разделе **Issues**.
4. Открой любой issue и изучи:

   | Раздел | Что показывает |
   |--------|----------------|
   | **Stack trace** | Точное место краша в коде |
   | **Device** | Модель устройства, версия ОС, свободная память |
   | **Keys** | Кастомные ключи (`screen`, `action` и др.) |
   | **Logs** | Логи перед крашем |
   | **Affected users** | Количество затронутых пользователей |

5. На **Dashboard** найди метрику **Crash-free users** — процент пользователей без крашей.

> 💡 В реальных проектах **Crash-free users > 99.5%** считается хорошим показателем. Ниже 99% — критично и требует немедленного внимания.

---

### 🔍 Проверка (Часть 1)

- [ ] Выполнена [Часть 0](#часть-0-настройка-проекта-firebase): в проекте твои конфиги Firebase, вызывается `Firebase.initializeApp()`
- [ ] В `pubspec.yaml` добавлен `firebase_crashlytics`, выполнен `flutter pub get`
- [ ] В `main.dart` настроены `FlutterError.onError` и `runZonedGuarded` для перехвата ошибок
- [ ] Тестовый краш (`FirebaseCrashlytics.instance.crash()`) вызван, приложение перезапущено
- [ ] В Firebase Console → **Crashlytics → Issues** виден отчёт о краше со стек-трейсом
- [ ] Нефатальная ошибка (`recordError`) отображается в Issues как **Non-fatal**
- [ ] В отчёте видны: стек-трейс, устройство, контекст падения, кастомные ключи (если добавлены)

---

### 🎓 Что показать на экзамене (Часть 1)

1. **Код:** покажи `main.dart` — перехват ошибок через `FlutterError.onError` и `runZonedGuarded`
2. **Тестовый краш:** в приложении нажми кнопку тестового краша → перезапусти приложение
3. **Firebase Console:** открой **Crashlytics → Issues** — покажи появившийся отчёт
4. **Детали отчёта:** открой issue — покажи стек-трейс, устройство, версию ОС
5. **Нефатальная ошибка:** покажи отдельную запись Non-fatal в списке Issues
6. **Crash-Free Users:** покажи метрику на Dashboard
7. **Фраза:** «Подключил Crashlytics, настроил перехват Flutter-ошибок и runZonedGuarded. Тестовый краш и нефатальная ошибка видны в консоли с полным контекстом — стек-трейсом, устройством и кастомными ключами.»

---

### 🛠 Траблшутинг (Часть 1)

**Crashlytics не видит крашей / отчёт не появляется**
→ Убедись, что выполнена [Часть 0](#часть-0-настройка-проекта-firebase), конфиги Firebase в проекте, `Firebase.initializeApp()` вызывается до любых обращений к Crashlytics. После фатального краша отчёт отправляется **при следующем запуске** приложения — обязательно перезапусти. Подожди 1–2 минуты и обнови страницу в консоли (F5).

**Ошибка `No Firebase App '[DEFAULT]' has been created`**
→ `Firebase.initializeApp()` не вызван или конфиги (`google-services.json` / `GoogleService-Info.plist`) не на месте. Перепроверь [Часть 0](#часть-0-настройка-проекта-firebase).

**Crashlytics пишет `Crashlytics collection is not enabled`**
→ Проверь, что в Firebase Console для твоего приложения Crashlytics включён (раздел Release & Monitor → Crashlytics → Enable).

**Нефатальные ошибки не появляются**
→ Убедись, что вызываешь `recordError` с корректным `stackTrace` (не `null`). Проверь наличие интернета на устройстве.

→ Больше решений: [FAQ — Firebase](../FAQ.md#firebase)

---

### 🧪 Практические сценарии (Часть 1)

#### Сценарий 1.1: Тестовый краш и анализ отчёта

1. Добавь в экран Настроек кнопку (или используй существующую) для вызова:
   ```dart
   FirebaseCrashlytics.instance.crash();
   ```
2. Нажми кнопку — приложение упадёт.
3. **Перезапусти** приложение (Crashlytics отправляет отчёт при следующем запуске).
4. Открой Firebase Console → **Crashlytics** → **Issues**.
5. Найди issue и изучи:
   - **Stack trace** — точное место краша
   - **Device** — модель, ОС, свободная память
   - **Keys** — кастомные ключи (если добавлены)
   - **Logs** — логи перед крашем
   - **Affected users** — количество затронутых пользователей

#### Сценарий 1.2: Нефатальная ошибка с контекстом

1. При ошибке загрузки курсов (включи авиарежим) запиши нефатальную ошибку с контекстом:
   ```dart
   FirebaseCrashlytics.instance.setCustomKey('screen', 'exchange');
   FirebaseCrashlytics.instance.setCustomKey('action', 'load_rates');
   FirebaseCrashlytics.instance.recordError(
     error,
     stack,
     reason: 'Ошибка загрузки курсов',
   );
   ```
2. В Firebase Console → **Crashlytics → Issues** — ошибка появится как **Non-fatal**.
3. Открой — увидишь кастомные ключи `screen: exchange`, `action: load_rates`.
4. **Зачем:** в реальном проекте это помогает понять, на каком экране и при каком действии происходят ошибки — без этого контекста искать причину гораздо сложнее.

#### Сценарий 1.3: Краш при конвертации валюты

1. Добавь тестовый краш при обмене с нулевым курсом:
   ```dart
   if (rate == 0) {
     FirebaseCrashlytics.instance.setCustomKey('currency_pair', 'RUB/USD');
     FirebaseCrashlytics.instance.setCustomKey('amount', amountText);
     throw Exception('Exchange rate is zero — cannot convert');
   }
   ```
2. Crashlytics поймает исключение через `runZonedGuarded` и покажет полный стек с ключами.

#### Сценарий 1.4: Отслеживание Crash-Free Users

1. После нескольких запусков без крашей проверь **Dashboard → Crash-free users**.
2. Значение должно быть ~100% (нет крашей).
3. Сделай краш → перезапусти → процент упадёт.
4. **Зачем:** в реальных проектах это ключевая метрика стабильности релиза. Падение ниже 99% — сигнал к экстренному хотфиксу.

---

## Часть 2: Cloud Messaging (FCM) — push-уведомления

> Подключаем push-уведомления через Firebase Cloud Messaging к FinControl: запрашиваем разрешения, получаем FCM-токен, обрабатываем уведомления в foreground и background. Результат — тестовый push из Firebase Console успешно доставлен на устройство.

---

### 🎯 Цель

Подключить **Firebase Cloud Messaging (FCM)** к приложению FinControl (твой проект Firebase): запросить разрешения, получить FCM-токен, настроить обработку уведомлений в **foreground** и **background**. Отправить тестовое push-уведомление из Firebase Console и убедиться, что приложение его получает и обрабатывает.

---

### ✅ Ожидаемый результат

- ✅ FCM инициализирован, разрешения запрошены (на iOS), FCM-токен получен и выведен в лог
- ✅ Из Firebase Console (Engage → Messaging) отправлено тестовое уведомление на устройство по токену
- ✅ В **foreground** уведомление обрабатывается через `onMessage` (SnackBar / локальное уведомление)
- ✅ В **background** уведомление появляется в системном трее
- ✅ При нажатии на уведомление срабатывает `onMessageOpenedApp`

---

### 📋 Что понадобится

| Что | Зачем |
|-----|-------|
| Выполненная [Часть 0](#часть-0-настройка-проекта-firebase) | Свой проект Firebase, конфиги в проекте, `Firebase.initializeApp()` в коде |
| Пакет `firebase_messaging` в `pubspec.yaml` | SDK для работы с push-уведомлениями |
| Реальное устройство (рекомендуется) | Для полноценного тестирования push |
| Доступ к [Firebase Console](https://console.firebase.google.com) | Для отправки тестовых уведомлений |
| **Только для iOS:** Apple Developer аккаунт | Настройка APNs-ключа |

> ⚠️ **Обязательно сначала выполни [Часть 0](#часть-0-настройка-проекта-firebase):** свой проект Firebase, свои конфиги (`google-services.json`, `GoogleService-Info.plist`), `Firebase.initializeApp()` в коде.

> 📌 Ключи Sentry/AppMetrica (практики 06–07) задаются в [STUDENT_ENV.md](../STUDENT_ENV.md) — не путай с Firebase-конфигами.

---

### 📝 Пошаговая инструкция

#### Шаг 2.1: Добавление зависимости

1. Открой `pubspec.yaml` в корне проекта.
2. Добавь зависимость `firebase_messaging`:
   ```yaml
   dependencies:
     firebase_core: ^3.0.0
     firebase_messaging: ^15.0.0
   ```
   > 💡 Актуальную версию смотри на [pub.dev/packages/firebase_messaging](https://pub.dev/packages/firebase_messaging) — она должна быть совместима с твоей версией `firebase_core`.

3. Установи зависимости:
   ```bash
   flutter pub get
   ```

#### Шаг 2.2: Настройка платформ

##### Android

1. Для базового FCM на Android специальных прав в манифесте не требуется.
2. Для **Android 13+** (API 33+) нужно запрашивать разрешение на уведомления в рантайме — это делается через `requestPermission()` (см. Шаг 2.3).
3. Для кастомного отображения уведомлений на **Android 8+** может понадобиться создание notification channel.

##### iOS

1. В **Xcode** открой проект iOS (`ios/Runner.xcworkspace`).
2. Перейди в **Signing & Capabilities**.
3. Нажми **+ Capability** и добавь:
   - **Push Notifications**
   - **Background Modes** → поставь галочку **Remote notifications**
4. В **Apple Developer Console** (developer.apple.com):
   - Перейди в **Keys** → создай ключ с включённым **Apple Push Notifications service (APNs)**
   - Скачай `.p8` файл ключа
5. В **Firebase Console** → **Project Settings** → **Cloud Messaging** → **Apple app configuration**:
   - Загрузи скачанный `.p8` файл
   - Укажи **Key ID** и **Team ID**

> ⚠️ Без настройки APNs push-уведомления на iOS работать **не будут**. Это самая частая ошибка.

#### Шаг 2.3: Инициализация FCM и запрос разрешений

1. В `lib/main.dart` добавь импорт и обработчик фоновых сообщений:

   ```dart
   import 'package:firebase_messaging/firebase_messaging.dart';

   // Обработчик фоновых сообщений — ДОЛЖЕН быть top-level функцией
   @pragma('vm:entry-point')
   Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
     await Firebase.initializeApp();
     // Обработка фонового сообщения (например, логирование)
     debugPrint('Background message: ${message.messageId}');
   }
   ```

2. В функции `main()` после `Firebase.initializeApp()` настрой FCM:

   ```dart
   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();

     // Регистрируем обработчик фоновых сообщений
     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

     // Запрашиваем разрешения (критично для iOS, на Android 13+ тоже нужно)
     final messaging = FirebaseMessaging.instance;
     final settings = await messaging.requestPermission(
       alert: true,
       badge: true,
       sound: true,
     );
     debugPrint('Разрешение: ${settings.authorizationStatus}');

     // Получаем FCM-токен — его используем для тестовой отправки
     final token = await messaging.getToken();
     debugPrint('FCM Token: $token');

     runApp(const FinControlRoot());
   }
   ```

> 📌 **FCM-токен** — это уникальный идентификатор устройства для push-уведомлений. Скопируй его из логов — он понадобится для отправки тестового push из консоли.

#### Шаг 2.4: Обработка уведомлений в foreground

1. В главном виджете приложения (или в `initState` корневого StatefulWidget) добавь слушатели:

   ```dart
   @override
   void initState() {
     super.initState();

     // Уведомление пришло, когда приложение открыто (foreground)
     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
       debugPrint('Foreground message: ${message.notification?.title}');
       // Покажи SnackBar или локальное уведомление
       if (message.notification != null) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(message.notification!.title ?? 'Новое уведомление')),
         );
       }
     });

     // Пользователь нажал на уведомление (приложение было в background)
     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
       debugPrint('Opened from notification: ${message.data}');
       // Навигация по данным из уведомления
       if (message.data['action'] == 'open_exchange') {
         Navigator.of(context).pushNamed('/exchange');
       }
     });
   }
   ```

> 💡 **Три состояния приложения при получении push:**
>
> | Состояние | Что происходит |
> |-----------|----------------|
> | **Foreground** | Срабатывает `onMessage` — уведомление НЕ показывается в трее автоматически |
> | **Background** | Уведомление появляется в системном трее; при нажатии — `onMessageOpenedApp` |
> | **Terminated** | Уведомление в трее; при нажатии — `getInitialMessage()` при запуске |

#### Шаг 2.5: Отправка тестового push из Firebase Console

1. Открой [Firebase Console](https://console.firebase.google.com) → твой проект.
2. В левом меню: **Engage** → **Messaging** (или **Cloud Messaging**).
3. Нажми **Create your first campaign** → выбери **Firebase Notification messages**.
4. Заполни:
   - **Notification title:** `Курсы обновлены!`
   - **Notification text:** `USD: 92.50 ₽ (+0.5%). Откройте обменник.`
5. Нажми **Send test message**.
6. Вставь **FCM-токен** (скопированный из логов приложения) и нажми **Test**.
7. Проверь результат:
   - **Приложение в foreground** → сработает `onMessage` (появится SnackBar)
   - **Приложение в background** → уведомление появится в системном трее
   - **Нажми на уведомление** → сработает `onMessageOpenedApp`

> 💡 Если не знаешь, где взять токен: запусти приложение и поищи в логах строку `FCM Token: eAbCd...`. На Android можно фильтровать: `adb logcat | grep "FCM Token"`. На iOS — смотри в Xcode Console.

---

### 🔍 Проверка (Часть 2)

- [ ] Выполнена [Часть 0](#часть-0-настройка-проекта-firebase)
- [ ] Пакет `firebase_messaging` добавлен в `pubspec.yaml`, выполнен `flutter pub get`
- [ ] Разрешения запрошены (`requestPermission`); на iOS — настроены APNs
- [ ] FCM-токен получается и выводится в лог (`debugPrint('FCM Token: $token')`)
- [ ] Тестовое push-уведомление из Firebase Console доставлено на устройство по токену
- [ ] В **foreground** — обработчик `onMessage` срабатывает
- [ ] В **background** — уведомление появляется в системном трее
- [ ] При нажатии на уведомление — `onMessageOpenedApp` срабатывает

---

### 🎓 Что показать на экзамене (Часть 2)

1. **Логи:** покажи в консоли FCM-токен (`debugPrint`)
2. **Firebase Console:** открой Engage → Messaging → создай тестовое уведомление
3. **Отправка:** отправь push на устройство по токену
4. **Foreground:** покажи, что уведомление обрабатывается через `onMessage` (SnackBar или лог)
5. **Background:** сверни приложение → покажи уведомление в системном трее
6. **Нажатие:** нажми на уведомление — приложение открывается, `onMessageOpenedApp` срабатывает
7. **Фраза:** «Подключил FCM, получил токен, отправил тестовый push из консоли — уведомление пришло и обрабатывается в foreground через onMessage и в background через системный трей.»

---

### 🛠 Траблшутинг (Часть 2)

**Уведомления не приходят вообще**
→ Проверь, что FCM-токен выводится в лог и правильно подставлен в консоль при отправке. Убедись, что устройство подключено к интернету.

**На iOS уведомления не приходят**
→ Самая частая причина — не настроены APNs. Проверь: в Xcode включены Push Notifications и Background Modes → Remote notifications; `.p8` ключ загружен в Firebase Console → Project Settings → Cloud Messaging.

**FCM-токен = null**
→ На iOS: APNs не настроены. На эмуляторе iOS FCM-токен может не генерироваться — используй реальное устройство. На Android: проверь наличие Google Play Services.

**В foreground уведомление не показывается**
→ Это нормальное поведение: в foreground уведомления **не** отображаются в трее автоматически. Нужно обрабатывать `onMessage` вручную и показывать SnackBar или использовать пакет `flutter_local_notifications`.

**Токен меняется при каждом запуске**
→ Токен может обновляться (при переустановке, обновлении Google Play Services). Используй `onTokenRefresh` для отслеживания:
```dart
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  debugPrint('New FCM Token: $newToken');
});
```

→ Больше решений: [FAQ — Firebase](../FAQ.md#firebase)

---

### 🧪 Практические сценарии (Часть 2)

#### Сценарий 2.1: Получение и проверка FCM-токена

1. Запусти приложение с подключённым FCM.
2. В логах найди строку:
   ```
   FCM Token: eAbCd...очень_длинная_строка...xYz
   ```
   - **Android:** `adb logcat | grep "FCM Token"`
   - **iOS:** в Xcode Console ищи `FCM Token`
3. Скопируй токен — он понадобится для отправки тестового push.
4. **Важно:** токен может меняться (при переустановке, обновлении Google Play Services). В реальном проекте его отправляют на сервер и обновляют через `onTokenRefresh`.

#### Сценарий 2.2: Полный флоу отправки push из консоли

1. Открой Firebase Console → **Engage → Messaging** → **Create your first campaign**.
2. Выбери **Firebase Notification messages**.
3. Заполни:
   - **Title:** `Курсы обновлены!`
   - **Text:** `USD: 92.50 ₽ (+0.5%). Откройте обменник.`
4. Нажми **Send test message** → вставь FCM-токен → **Test**.
5. Проверь все три сценария:

   | Тест | Действие | Ожидаемый результат |
   |------|----------|---------------------|
   | Foreground | Приложение открыто | `onMessage` срабатывает, показывается SnackBar |
   | Background | Приложение свёрнуто | Уведомление в системном трее |
   | Tap | Нажать на уведомление | `onMessageOpenedApp` срабатывает |

#### Сценарий 2.3: Push с кастомными данными (deep link)

1. В Firebase Console при создании push добавь **Custom data** (Additional options → Custom data):
   - Key: `action`, Value: `open_exchange`
   - Key: `currency`, Value: `USD`
2. В обработчике `onMessageOpenedApp` добавь навигацию:
   ```dart
   FirebaseMessaging.onMessageOpenedApp.listen((message) {
     if (message.data['action'] == 'open_exchange') {
       Navigator.of(context).pushNamed('/exchange');
     }
   });
   ```
3. **Результат:** при нажатии на push приложение открывает экран Обменника — это и есть deep link через push.

#### Сценарий 2.4: Topic Messaging — групповые уведомления

1. Подпиши устройство на тему:
   ```dart
   await FirebaseMessaging.instance.subscribeToTopic('rate_alerts');
   debugPrint('Подписан на тему rate_alerts');
   ```
2. В Firebase Console при создании кампании в **Targeting** выбери **Topic** → `rate_alerts`.
3. Отправь — все подписанные устройства получат уведомление.
4. **Зачем:** в реальном проекте так рассылают уведомления по сегментам (например, пользователям, которые следят за курсом USD).

> 💡 **Notification vs Data Messages:**
> - **Notification Messages** — показываются системой автоматически в background, обрабатываются `onMessage` в foreground
> - **Data Messages** — обрабатываются только кодом (через `onMessage` / `onBackgroundMessage`), не показываются автоматически. Используй их, когда хочешь полный контроль над отображением

---

## Часть 3: Analytics — события и воронки

> Подключаем Firebase Analytics к FinControl, чтобы логировать ключевые действия пользователя: открытие экранов, обмен валюты, операции в портфеле. Результат — события видны в Firebase Console (Events и DebugView), можно строить воронки конверсии.

---

### 🎯 Цель

Включить **Firebase Analytics** в приложении FinControl (твой проект Firebase), настроить логирование экранов и кастомных событий, просмотреть их в Firebase Console (**Events**, **DebugView**) и построить простую воронку конверсии по действиям пользователя.

---

### ✅ Ожидаемый результат

- ✅ Analytics подключён, события логируются при действиях пользователя (`screen_view`, `exchange_completed`, `portfolio_buy` и др.)
- ✅ В Firebase Console → **Analytics → Events** видны все события с количеством срабатываний
- ✅ В **DebugView** события отображаются в реальном времени (без задержки)
- ✅ Построена простая воронка конверсии (например: открытие Обменника → совершение обмена)

---

### 📋 Что понадобится

| Что | Зачем |
|-----|-------|
| Выполненная [Часть 0](#часть-0-настройка-проекта-firebase) | Свой проект Firebase, конфиги в проекте, `Firebase.initializeApp()` в коде |
| Пакет `firebase_analytics` в `pubspec.yaml` | SDK для логирования событий |
| Реальное устройство или эмулятор | Для генерации событий |
| Доступ к [Firebase Console](https://console.firebase.google.com) | Для просмотра Events и DebugView |

> ⚠️ **Обязательно сначала выполни [Часть 0](#часть-0-настройка-проекта-firebase):** свой проект Firebase, свои конфиги, `Firebase.initializeApp()` в коде.

> 📌 Ключи Sentry/AppMetrica (практики 06–07) задаются в [STUDENT_ENV.md](../STUDENT_ENV.md) — не путай с Firebase-конфигами.

---

### 📝 Пошаговая инструкция

#### Шаг 3.1: Добавление зависимости

1. Открой `pubspec.yaml` в корне проекта.
2. Добавь зависимость `firebase_analytics`:
   ```yaml
   dependencies:
     firebase_core: ^3.0.0
     firebase_analytics: ^11.0.0
   ```
   > 💡 Актуальную версию смотри на [pub.dev/packages/firebase_analytics](https://pub.dev/packages/firebase_analytics) — она должна быть совместима с твоей версией `firebase_core`.

3. Установи зависимости:
   ```bash
   flutter pub get
   ```

#### Шаг 3.2: Инициализация Analytics

1. Analytics обычно включается **автоматически** после `Firebase.initializeApp()` (по [Части 0](#часть-0-настройка-проекта-firebase)).
2. Для явного использования создай экземпляр:
   ```dart
   import 'package:firebase_analytics/firebase_analytics.dart';

   final analytics = FirebaseAnalytics.instance;
   ```

> 💡 Никакой дополнительной инициализации не нужно — после `Firebase.initializeApp()` Analytics уже работает и собирает базовые события (first_open, session_start и др.).

#### Шаг 3.3: Автоматическое логирование экранов

1. Для автоматического отслеживания переходов между экранами добавь `FirebaseAnalyticsObserver` в `MaterialApp`:

   ```dart
   import 'package:firebase_analytics/firebase_analytics.dart';

   final analytics = FirebaseAnalytics.instance;

   MaterialApp(
     navigatorObservers: [
       FirebaseAnalyticsObserver(analytics: analytics),
     ],
     // ...остальные параметры
   );
   ```

2. Теперь каждый переход между именованными маршрутами автоматически логируется как `screen_view`.

3. Для ручного логирования экрана (например, при использовании `go_router` или вкладок):
   ```dart
   await analytics.logScreenView(
     screenName: 'ExchangeScreen',
     screenClass: 'ExchangeScreen',
   );
   ```

#### Шаг 3.4: Логирование кастомных событий

1. Добавь вызовы `logEvent` в ключевых точках приложения.

   **Обмен валюты** (после успешной конвертации):
   ```dart
   await analytics.logEvent(
     name: 'exchange_completed',
     parameters: {
       'currency_from': 'RUB',
       'currency_to': 'USD',
       'amount': 1000,
     },
   );
   ```

   **Покупка в портфеле:**
   ```dart
   await analytics.logEvent(
     name: 'portfolio_buy',
     parameters: {
       'currency': 'USD',
       'amount': 100,
       'rate': 92.5,
     },
   );
   ```

   **Продажа из портфеля:**
   ```dart
   await analytics.logEvent(
     name: 'portfolio_sell',
     parameters: {
       'currency': 'USD',
       'amount': 50,
       'rate': 93.0,
     },
   );
   ```

   **Добавление расхода:**
   ```dart
   await analytics.logEvent(
     name: 'expense_added',
     parameters: {
       'category': 'Еда',
       'amount': 500,
       'is_income': false,
       'source': 'quick_add', // или 'full_form'
     },
   );
   ```

> 📌 **Правила именования событий Firebase Analytics:**
> - Имя события: до 40 символов, только буквы, цифры и `_` (snake_case)
> - Параметр: до 40 символов для ключа, до 100 символов для строкового значения
> - Максимум 25 параметров на событие
> - Не используй префикс `firebase_` или `google_` — они зарезервированы

#### Шаг 3.5: Включение DebugView (события в реальном времени)

По умолчанию события в Firebase Console появляются с **задержкой до нескольких часов**. Для мгновенного просмотра включи режим отладки:

**Android:**
```bash
adb shell setprop debug.firebase.analytics.app com.yourname.fincontrol.fin_control
```

> 💡 Замени `com.yourname.fincontrol.fin_control` на **applicationId** твоего приложения (смотри в `android/app/build.gradle` → `applicationId`).

**iOS:**
В Xcode: **Product → Scheme → Edit Scheme → Run → Arguments → Arguments Passed On Launch** → добавь:
```
-FIRDebugEnabled
```

**Чтобы отключить** режим отладки:
```bash
# Android
adb shell setprop debug.firebase.analytics.app .none.

# iOS — добавь аргумент -FIRDebugDisabled вместо -FIRDebugEnabled
```

#### Шаг 3.6: Просмотр в Firebase Console

1. Открой [Firebase Console](https://console.firebase.google.com) → твой проект.
2. В левом меню: **Analytics**.

   | Раздел | Что показывает | Задержка |
   |--------|----------------|----------|
   | **DebugView** | События в реальном времени от отладочных устройств | Мгновенно |
   | **Events** | Список всех событий с количеством срабатываний | До нескольких часов |
   | **Explore** (Explorations) | Кастомные отчёты и воронки | До нескольких часов |

3. **DebugView:** перейди в Analytics → DebugView — увидишь поток событий в реальном времени от устройства с включённым debug mode.
4. **Events:** перейди в Analytics → Events — увидишь список событий и количество срабатываний.

#### Шаг 3.7: Построение воронки конверсии

1. В Firebase Console перейди в **Analytics → Explore** (или **Explorations**).
2. Нажми **Create new exploration** → выбери шаблон **Funnel Analysis**.
3. Настрой воронку, например:

   **Воронка «Обмен валюты»:**
   - Шаг 1: `screen_view` (параметр `firebase_screen: ExchangeScreen`)
   - Шаг 2: `exchange_completed`
   - **Вопрос:** какой процент пользователей, открывших Обменник, реально совершает обмен?

   **Воронка «Покупка в портфеле»:**
   - Шаг 1: `screen_view` (параметр `firebase_screen: PortfolioScreen`)
   - Шаг 2: `portfolio_buy`

4. Анализируй результаты: на каком шаге теряются пользователи?

> 💡 Воронки доступны только после накопления данных (может потребоваться несколько часов после первых событий). Для быстрой проверки — используй DebugView.

---

### 🔍 Проверка (Часть 3)

- [ ] Выполнена [Часть 0](#часть-0-настройка-проекта-firebase)
- [ ] Пакет `firebase_analytics` добавлен в `pubspec.yaml`, выполнен `flutter pub get`
- [ ] `FirebaseAnalyticsObserver` добавлен в `navigatorObservers` (или используется ручное логирование экранов)
- [ ] Кастомные события (`exchange_completed`, `portfolio_buy` и др.) вызываются в коде при действиях пользователя
- [ ] Включён DebugView (debug mode на устройстве)
- [ ] В Firebase Console → **Analytics → DebugView** видны события в реальном времени
- [ ] В Firebase Console → **Analytics → Events** видны события со счётчиками
- [ ] Построена простая воронка конверсии (если данных достаточно)

---

### 🎓 Что показать на экзамене (Часть 3)

1. **Код:** покажи вызовы `logEvent` и `logScreenView` / `FirebaseAnalyticsObserver` в приложении
2. **Действия в приложении:** открой Обменник → сделай обмен → открой Портфель → купи валюту
3. **DebugView:** открой Firebase Console → Analytics → **DebugView** — покажи события в реальном времени
4. **Events:** открой **Events** — покажи список событий с количеством срабатываний
5. **Воронка:** покажи построенную воронку в Explorations (если доступно)
6. **Фраза:** «Подключил Firebase Analytics, логирую экраны и ключевые действия. В DebugView вижу события в реальном времени, в Events — статистику. Построил воронку конверсии для обмена валюты.»

---

### 🛠 Траблшутинг (Часть 3)

**События не видны в Firebase Console**
→ Обычная задержка — до нескольких часов. Для мгновенного просмотра включи **DebugView** (см. Шаг 3.5). Убедись, что выполнена [Часть 0](#часть-0-настройка-проекта-firebase) и `Firebase.initializeApp()` вызывается.

**DebugView пустой / устройство не появляется**
→ Проверь, что debug mode включён на устройстве (adb-команда для Android или аргумент `-FIRDebugEnabled` для iOS). Перезапусти приложение после включения.

**Событие `logEvent` вызывает ошибку**
→ Проверь имя события: только буквы, цифры и `_`, до 40 символов, без пробелов, без префиксов `firebase_` / `google_`.

**Воронки недоступны в Explorations**
→ Для воронок нужно накопить данные (несколько часов). Также Explorations может быть недоступен на бесплатном плане для некоторых функций — но базовые воронки работают.

**Дубликаты событий `screen_view`**
→ Если используешь и `FirebaseAnalyticsObserver`, и ручной `logScreenView` — будут дубли. Выбери один способ.

→ Больше решений: [FAQ — Firebase](../FAQ.md#firebase)

---

### 🧪 Практические сценарии (Часть 3)

#### Сценарий 3.1: Логирование полного пользовательского пути

1. Убедись, что `FirebaseAnalyticsObserver` подключён (или добавлены ручные вызовы `logScreenView`).
2. Пройди полный путь по приложению:
   **Welcome → Начать → Список → Обменник → обмен валюты → Портфель → покупка → Статистика**
3. В Firebase Console → **Analytics → DebugView** увидишь поток событий в реальном времени:
   ```
   screen_view (WelcomeScreen)
   screen_view (ShellScreen)
   screen_view (ExchangeScreen)
   exchange_completed
   screen_view (PortfolioScreen)
   portfolio_buy
   screen_view (StatsScreen)
   ```
4. **Зачем:** в реальном проекте это помогает понять, как пользователи двигаются по приложению и где «застревают».

#### Сценарий 3.2: Построение воронки конверсии

1. В Firebase Console → **Analytics → Explore** (Explorations).
2. Создай **Funnel Analysis**:
   - Шаг 1: `screen_view` (параметр `firebase_screen: ExchangeScreen`)
   - Шаг 2: `exchange_completed`
3. **Вопрос:** какой процент пользователей, открывших Обменник, совершает обмен?
4. Добавь ещё одну воронку:
   - Шаг 1: `screen_view` (параметр `firebase_screen: PortfolioScreen`)
   - Шаг 2: `portfolio_buy`
5. **Вывод для продакта:** если конверсия низкая — возможно, интерфейс обмена слишком сложный и нужно упрощать.

#### Сценарий 3.3: Сравнение способов добавления расходов

1. Добавь расходы обоими способами:
   - **Быстрая запись** (параметр `source: 'quick_add'`)
   - **Полная форма** (параметр `source: 'full_form'`)
2. В **Events → expense_added** фильтруй по параметру `source`:
   - Сколько через `quick_add`?
   - Сколько через `full_form`?
3. **Вывод для продакта:** какой способ популярнее? Нужно ли упрощать полную форму или делать быструю запись более заметной?

#### Рекомендуемые события для FinControl

| Событие | Когда срабатывает | Параметры |
|---------|-------------------|-----------|
| `screen_view` | Открытие любого экрана | `screen_name`, `screen_class` |
| `expense_added` | Добавление расхода/дохода | `category`, `amount`, `is_income`, `source` |
| `exchange_completed` | Конвертация валюты | `currency_from`, `currency_to`, `amount` |
| `portfolio_buy` | Покупка валюты в портфеле | `currency`, `amount`, `rate` |
| `portfolio_sell` | Продажа из портфеля | `currency`, `amount`, `rate` |
| `alert_created` | Создание ценового алерта | `currency_pair`, `target_rate` |
| `goal_created` | Создание цели накоплений | `title`, `target_amount` |
| `theme_toggled` | Переключение темы | `theme` (`light` / `dark`) |
| `data_cleared` | Очистка всех данных | — |

---

## Часть 4: Remote Config — управление без релиза

> Управляй поведением приложения **без обновления сборки**: создай параметры в Firebase Console, прочитай их в коде через `fetchAndActivate()` — и меняй UI, тексты, логику на лету. Идеально для A/B тестов и постепенного раскатывания фич.

---

### 🎯 Цель

Подключить **Firebase Remote Config** к приложению FinControl (твой проект Firebase), создать параметры (фичефлаги и значения) в консоли, изменить их — и убедиться, что приложение после `fetchAndActivate()` получает новые значения и меняет поведение (скрытие вкладки, отображение комиссии, изменение текста).

---

### ✅ Ожидаемый результат

- [x] Параметры созданы в Firebase Console → **Remote Config** и опубликованы
- [x] Приложение при старте (или по кнопке «Обновить конфиг») вызывает `fetchAndActivate()` и читает значения
- [x] Изменение значения в консоли + повторный fetch → поведение приложения меняется без обновления сборки
- [x] Понимание принципов Conditions и rollout (постепенная раскатка)

---

### 📋 Что понадобится

| Что | Зачем |
|-----|-------|
| Выполненная [Часть 0](#часть-0-настройка-проекта-firebase) | Свой проект Firebase, конфиги в проекте, `Firebase.initializeApp()` в коде |
| `firebase_remote_config` | Пакет для Flutter — совместимый с твоей версией `firebase_core` |
| Firebase Console | Доступ к разделу **Remote Config** |
| Часть 3 (желательно) | [Часть 3: Analytics](#часть-3-analytics--события-и-воронки) — для связки с A/B тестами |

> ⚠️ **Важно:** сначала выполни [Часть 0](#часть-0-настройка-проекта-firebase) — свой проект, свои конфиги, `Firebase.initializeApp()`. Ключи Sentry/AppMetrica (практики 06–07) — в [STUDENT_ENV.md](../STUDENT_ENV.md), не здесь.

---

### 📝 Пошаговая инструкция

#### Шаг 4.1: Подключение пакета

1. Открой файл `pubspec.yaml` в корне проекта.
2. Добавь зависимость (если её ещё нет):
   ```yaml
   dependencies:
     firebase_remote_config: ^4.0.0  # версия совместимая с твоим firebase_core
   ```
3. Выполни установку:
   ```bash
   flutter pub get
   ```
4. Убедись, что в `main.dart` уже вызван `Firebase.initializeApp()` (по [Части 0](#часть-0-настройка-проекта-firebase)).

#### Шаг 4.2: Инициализация Remote Config в коде

1. В файле, где происходит инициализация (например `main.dart` или отдельный сервис), добавь импорт и функцию:

   ```dart
   import 'package:firebase_remote_config/firebase_remote_config.dart';

   final remoteConfig = FirebaseRemoteConfig.instance;

   Future<void> initRemoteConfig() async {
     // Настройки: таймаут запроса и интервал между обновлениями
     await remoteConfig.setConfigSettings(RemoteConfigSettings(
       fetchTimeout: const Duration(seconds: 10),
       minimumFetchInterval: const Duration(hours: 1), // в debug можно Duration.zero
     ));

     // Значения по умолчанию — используются до первого успешного fetch
     await remoteConfig.setDefaults({
       'show_portfolio': true,
       'commission_percent': 0.0,
       'welcome_message': 'Добро пожаловать в FinControl!',
     });

     // Загрузка и активация параметров с сервера
     await remoteConfig.fetchAndActivate();
   }
   ```

2. Вызови `initRemoteConfig()` при старте приложения — после `Firebase.initializeApp()`:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     await initRemoteConfig(); // <-- вот здесь
     runApp(const MyApp());
   }
   ```

> 💡 **Подсказка:** в debug-режиме для быстрого тестирования выставь `minimumFetchInterval: Duration.zero` — тогда значения обновятся мгновенно при каждом fetch.

#### Шаг 4.3: Создание параметров в Firebase Console

1. Открой **Firebase Console** → твой проект → **Remote Config** (в меню слева, раздел **Run** или **Build**).
2. Нажми **Add parameter** (или «Добавить параметр»).
3. Создай первый параметр:
   - **Parameter name:** `show_portfolio`
   - **Data type:** Boolean
   - **Default value:** `true`
4. Создай второй параметр:
   - **Parameter name:** `commission_percent`
   - **Data type:** Number
   - **Default value:** `0`
5. При необходимости добавь **Conditions** (см. раздел ниже).
6. Нажми **Publish changes** — это обязательно, без публикации изменения не применятся!

> ⚠️ **Не забудь нажать Publish changes!** Частая ошибка — создать параметр, но не опубликовать. Без публикации приложение не получит значения.

#### Шаг 4.4: Чтение параметров в приложении

1. Создай геттеры для удобного доступа к параметрам:
   ```dart
   // Показывать ли вкладку Портфель
   bool get showPortfolio => remoteConfig.getBool('show_portfolio');

   // Комиссия при обмене (%)
   double get commissionPercent => remoteConfig.getDouble('commission_percent');

   // Приветственное сообщение
   String get welcomeMessage => remoteConfig.getString('welcome_message');
   ```

2. Используй в UI. Например, скрой вкладку «Портфель»:
   ```dart
   if (showPortfolio)
     NavigationDestination(
       icon: Icon(Icons.account_balance_wallet),
       label: 'Портфель',
     ),
   ```

3. Покажи комиссию на экране обмена:
   ```dart
   if (commissionPercent > 0)
     Text('Комиссия: ${commissionPercent}%',
       style: TextStyle(color: Colors.red)),
   ```

#### Шаг 4.5: Проверка rollout — изменение на лету

1. В **Firebase Console → Remote Config** измени значение параметра:
   - Например, выключи `show_portfolio` → `false`.
2. Нажми **Publish changes**.
3. В приложении вызови `fetchAndActivate()` заново:
   - Перезапусти приложение, **или**
   - Добавь кнопку «Обновить конфиг» для удобства тестирования:
     ```dart
     ElevatedButton(
       onPressed: () async {
         await remoteConfig.fetchAndActivate();
         setState(() {}); // перерисовка UI
       },
       child: Text('Обновить конфиг'),
     )
     ```
4. Убедись, что поведение изменилось — вкладка «Портфель» исчезла.

> 📌 **Запомни:** Remote Config кэширует значения. В production интервал обновления — 1 час и более. В debug с `Duration.zero` обновление мгновенное.

---

### 🧪 Практические сценарии (Часть 4)

#### Сценарий 4.1: Фичефлаг — скрытие вкладки

1. В Firebase Console → Remote Config → параметр `show_portfolio` (Boolean, default: `true`).
2. **Publish changes**.
3. В коде после `fetchAndActivate()` читай:
   ```dart
   final showPortfolio = remoteConfig.getBool('show_portfolio');
   ```
4. Используй в ShellScreen для скрытия/показа вкладки Портфель.
5. В консоли измени `show_portfolio` → `false` → **Publish** → в приложении сделай fetchAndActivate → вкладка исчезнет.

#### Сценарий 4.2: A/B тест комиссии

1. Добавь параметр `commission_percent` (Number, default: `0`).
2. Добавь **Condition**: «50% пользователей» → значение `1.5`.
3. **Publish**.
4. В коде при обмене учитывай комиссию:
   ```dart
   final commission = remoteConfig.getDouble('commission_percent');
   final finalAmount = toAmount * (1 - commission / 100);
   ```
5. **Результат:** 50% пользователей видят комиссию 1.5%, остальные — без комиссии.

#### Сценарий 4.3: Динамический текст

1. Добавь параметр `welcome_message` (String, default: `Добро пожаловать в FinControl!`).
2. В WelcomeScreen подставь значение из Remote Config.
3. Меняй текст в консоли — приложение обновляет его при следующем запуске без обновления в магазине.

---

### Рекомендуемые параметры для FinControl

| Параметр | Тип | Описание | Как использовать |
|----------|-----|----------|------------------|
| `show_portfolio` | Boolean | Показывать вкладку Портфель | Скрывать/показывать tab в навигации |
| `show_stocks` | Boolean | Показывать вкладку Акции | Скрывать/показывать tab |
| `commission_percent` | Number | Комиссия при обмене (%) | Подпись «Комиссия: N%» на экране обмена |
| `maintenance_mode` | Boolean | Режим обслуживания | Баннер «Приложение на обслуживании» |
| `welcome_message` | String | Текст приветственного экрана | Менять текст без обновления |
| `max_expense_amount` | Number | Максимальная сумма расхода | Валидация формы добавления расхода |

---

### Conditions — целевые аудитории

В Firebase Console → Remote Config → **Conditions** можно создавать правила таргетирования:

| Условие | Пример |
|---------|--------|
| По стране (Geo) | `commission_percent = 2.0` для RU |
| По версии приложения | Новый UI только для v2.0+ |
| По платформе | Android / iOS |
| По проценту пользователей | Rollout: 10% → 50% → 100% |

> 💡 **Совет для экзамена:** покажи Condition «50% пользователей» для `commission_percent` — это наглядно демонстрирует A/B тестирование.

---

### minimumFetchInterval

В debug для быстрого тестирования уменьши интервал:
```dart
await remoteConfig.setConfigSettings(RemoteConfigSettings(
  fetchTimeout: const Duration(seconds: 10),
  minimumFetchInterval: Duration.zero, // мгновенное обновление в debug
));
```

> ⚠️ **В production** оставь 1 час или больше — иначе Firebase заблокирует запросы (throttling). Это защита от слишком частых обращений.

---

### 🔍 Проверка (Часть 4)

- [ ] Выполнена [Часть 0](#часть-0-настройка-проекта-firebase)
- [ ] Пакет `firebase_remote_config` добавлен и установлен
- [ ] Параметры созданы в Firebase Console → **Remote Config** и опубликованы (Publish changes)
- [ ] Приложение получает значения после `fetchAndActivate()` (при старте или по кнопке)
- [ ] Изменение значения в консоли + повторный fetch → поведение UI изменилось
- [ ] Понимаешь разницу между default-значениями (в коде) и серверными (в консоли)

---

### 🎓 Что показать на экзамене (Часть 4)

1. **Firebase Console** → Remote Config → покажи созданные параметры (например `show_portfolio`, `commission_percent`)
2. **Запусти приложение** — продемонстрируй, что параметры читаются: портфель виден/скрыт, комиссия отображается/нет
3. **Измени значение** в консоли → Publish → в приложении вызови fetchAndActivate → покажи изменение поведения в реальном времени
4. **Резюмируй:** «Настроил Remote Config с параметрами. Изменил значение в консоли — приложение обновило поведение после fetch без обновления сборки»

---

### 🛠 Траблшутинг (Часть 4)

| Проблема | Решение |
|----------|---------|
| **Значения не обновляются** | Убедись, что вызван `fetchAndActivate()` при старте или по кнопке. Проверь, что в консоли нажат **Publish changes** |
| **Throttling — слишком частые запросы** | В production `minimumFetchInterval` должен быть >= 1 час. В debug можно `Duration.zero` |
| **Используются default-значения вместо серверных** | Проверь имя параметра — оно должно совпадать в коде и в консоли. Проверь, что fetch прошёл успешно |
| **Приложение не подключено к Firebase** | Убедись, что выполнена [Часть 0](#часть-0-настройка-проекта-firebase), конфиги на месте |

Подробнее: [FAQ — Firebase](../FAQ.md#firebase)

---

## Часть 5: Performance Monitoring — скорость и регрессии

> Измеряй скорость ключевых операций в приложении: запуск, загрузка курсов, HTTP-запросы. Сравнивай метрики между версиями — находи регрессии до того, как их найдут пользователи. Всё автоматически попадает в Firebase Console.

---

### 🎯 Цель

Подключить **Firebase Performance Monitoring** к приложению FinControl (твой проект Firebase), собрать автоматические трейсы (запуск приложения, HTTP-запросы) и кастомный трейс загрузки курсов (`load_rates`), просматривать метрики в консоли и сравнивать версии на предмет регрессий по скорости.

---

### ✅ Ожидаемый результат

- [x] Performance Monitoring включён и собирает данные
- [x] Автоматические метрики (App start) отображаются в Firebase Console
- [x] Кастомный трейс `load_rates` (загрузка курсов) добавлен и виден в Traces
- [x] HTTP-мониторинг настроен через `HttpMetric`
- [x] Понимание, как искать регрессии между версиями по метрикам

---

### 📋 Что понадобится

| Что | Зачем |
|-----|-------|
| Выполненная [Часть 0](#часть-0-настройка-проекта-firebase) | Свой проект Firebase, конфиги в проекте, `Firebase.initializeApp()` в коде |
| `firebase_performance` | Пакет для Flutter — совместимый с твоей версией `firebase_core` |
| Firebase Console | Доступ к разделу **Performance** |
| Реальное устройство или эмулятор | Для генерации метрик |

> ⚠️ **Важно:** сначала выполни [Часть 0](#часть-0-настройка-проекта-firebase) — свой проект, свои конфиги, `Firebase.initializeApp()`. Ключи Sentry/AppMetrica (практики 06–07) — в [STUDENT_ENV.md](../STUDENT_ENV.md), не здесь.

---

### 📝 Пошаговая инструкция

#### Шаг 5.1: Подключение пакета

1. Открой файл `pubspec.yaml` в корне проекта.
2. Добавь зависимость (если её ещё нет):
   ```yaml
   dependencies:
     firebase_performance: ^0.10.0  # версия совместимая с твоим firebase_core
   ```
3. Выполни установку:
   ```bash
   flutter pub get
   ```
4. Убедись, что в `main.dart` уже вызван `Firebase.initializeApp()` (по [Части 0](#часть-0-настройка-проекта-firebase)).

> 💡 **Подсказка:** после `Firebase.initializeApp()` Performance автоматически начинает собирать базовые метрики — **App start** (время до первого кадра). Дополнительный код для этого не нужен.

#### Шаг 5.2: Добавление кастомного трейса

1. Импортируй пакет в файл, где загружаются курсы (например сервис или экран обменника):
   ```dart
   import 'package:firebase_performance/firebase_performance.dart';
   ```

2. Оберни загрузку курсов в трейс:
   ```dart
   Future<void> loadRates() async {
     // Создаём кастомный трейс
     final trace = FirebasePerformance.instance.newTrace('load_rates');
     await trace.start();

     try {
       // Загрузка курсов — то, что измеряем
       await RatesApi.fetch();
     } finally {
       // Останавливаем трейс в любом случае (даже при ошибке)
       await trace.stop();
     }
   }
   ```

3. Вызови `loadRates()` при открытии экрана обменника или главного экрана.

> 📌 **Принцип:** `newTrace('имя')` → `start()` → выполняем операцию → `stop()`. Всё между start и stop — это измеряемая длительность.

#### Шаг 5.3: HTTP Monitoring

Для детального отслеживания HTTP-запросов используй `HttpMetric`:

```dart
import 'package:firebase_performance/firebase_performance.dart';
import 'package:http/http.dart' as http;

Future<http.Response> fetchWithMonitoring(Uri uri) async {
  // Создаём HTTP-метрику
  final metric = FirebasePerformance.instance.newHttpMetric(
    uri.toString(),
    HttpMethod.Get,
  );
  await metric.start();

  try {
    final response = await http.get(uri);

    // Заполняем метаданные ответа
    metric
      ..responsePayloadSize = response.contentLength ?? 0
      ..httpResponseCode = response.statusCode
      ..responseContentType = response.headers['content-type'];

    return response;
  } finally {
    await metric.stop();
  }
}
```

В Firebase Console → Performance → **Network** увидишь: URL, время ответа, размер, статус — для каждого запроса.

#### Шаг 5.4: Custom Attributes (дополнительная детализация)

Добавь атрибуты к трейсу для более глубокого анализа:

```dart
final trace = FirebasePerformance.instance.newTrace('load_rates');

// Атрибуты — строковые метки для фильтрации
trace.putAttribute('provider', 'exchangerate.host');
trace.putAttribute('from_cache', 'false');

await trace.start();
// ... загрузка курсов ...

// Числовые метрики — счётчики внутри трейса
trace.incrementMetric('rates_count', rates.length);

await trace.stop();
```

> 💡 **Зачем атрибуты:** в консоли можно отфильтровать трейсы по `from_cache = true/false` и сравнить время загрузки из кэша vs. из сети.

#### Шаг 5.5: Просмотр данных в Firebase Console

1. Открой **Firebase Console** → твой проект → **Performance**.
2. **Dashboard** — обзор: время запуска приложения, время до интерактивности.
3. **Traces** — список всех трейсов:
   - Автоматические (App start)
   - Кастомные (`load_rates` и другие, которые ты добавил)
4. **Network** — HTTP-запросы (если настроен `HttpMetric`): URL, время, размер, статус.

> ⚠️ **Данные появляются с задержкой** — от нескольких минут до 24 часов. Это нормально. Не паникуй, если сразу после запуска ничего не видно.

---

### Рекомендуемые метрики и трейсы

| Метрика / трейс | Описание | Где смотреть |
|-----------------|----------|--------------|
| **App start** | Время до первого кадра (автоматически) | Performance → Dashboard, Traces |
| **load_rates** | Время загрузки курсов (сеть или кэш) | Traces → кастомный трейс |
| **Network** | Длительность HTTP-запросов к API курсов | Performance → Network |

Дополнительные трейсы по тому же шаблону `newTrace('имя')` → `start()` → операция → `stop()`:

| Трейс | Что измеряет |
|-------|-------------|
| `open_exchange_screen` | Время открытия экрана обменника |
| `save_expense` | Время сохранения расхода в БД |
| `load_stocks` | Время загрузки списка акций |
| `portfolio_calculation` | Время расчёта портфеля |

---

### Как искать регрессии

#### Алгоритм поиска регрессий по шагам

1. **Фиксация базовой версии:** после стабильной сборки посмотри в Firebase Console → Performance → Traces среднюю длительность `load_rates` и App start для выбранного типа устройств.

2. **После изменений:** сделай новую сборку, установи на то же или похожее устройство, повтори сценарий (открытие приложения, переход на экран с курсами). Дождись появления данных в Performance.

3. **Сравнение:** в Traces выбери трейс `load_rates`, отфильтруй по версии приложения. Сравни метрики «до» и «после». Рост длительности при тех же условиях = возможная регрессия.

4. **Учёт сети:** регрессия — рост времени при сопоставимой сети. Фильтруй по скорости сети в отчёте или сравнивай только схожие условия.

5. **Что проверять при регрессии:** последние правки в `RatesApi`, экранах обменника/главной, в коде инициализации БД и загрузки кэша — не появились ли синхронные тяжёлые операции на main isolate.

> 💡 **Совет:** фильтруй по устройству/ОС — регресс может проявляться только на части устройств (например, только на старых Android).

---

### 🔍 Проверка (Часть 5)

- [ ] Выполнена [Часть 0](#часть-0-настройка-проекта-firebase)
- [ ] Пакет `firebase_performance` добавлен и установлен
- [ ] Performance Monitoring включён; данные появляются в Firebase Console
- [ ] Кастомный трейс `load_rates` добавлен в коде и отображается в **Performance → Traces**
- [ ] HTTP Monitoring настроен через `HttpMetric` (хотя бы для одного запроса)
- [ ] По отчётам можно оценить время ключевых операций и сравнить версии

---

### 🎓 Что показать на экзамене (Часть 5)

1. **Firebase Console** → Performance → **Dashboard** — покажи метрики запуска приложения
2. **Traces** — покажи кастомный трейс `load_rates` с метриками длительности
3. **Network** — покажи HTTP-запросы (если настроен HttpMetric)
4. **Код** — покажи, где в коде создаётся трейс (`newTrace → start → stop`)
5. **Резюмируй:** «Подключил Performance Monitoring, добавил кастомный трейс загрузки курсов. В консоли вижу время операций и могу сравнить сборки на предмет регрессий»

---

### 🛠 Траблшутинг (Часть 5)

| Проблема | Решение |
|----------|---------|
| **Данные не появляются** | Задержка до 24 часов — это нормально. Убедись, что `Firebase.initializeApp()` вызван и трейсы start/stop в коде |
| **Кастомный трейс не виден** | Проверь, что вызваны и `start()`, и `stop()`. Трейс без `stop()` не отправится |
| **Network пуст** | HttpMetric нужно создавать вручную (см. Шаг 5.3). Автоматический перехват HTTP в Flutter ограничен |
| **Приложение не подключено к Firebase** | Выполни [Часть 0](#часть-0-настройка-проекта-firebase), проверь конфиги |

Подробнее: [FAQ — Firebase](../FAQ.md#firebase)

---

## Часть 6: In-App Messaging — кампании внутри приложения

> Показывай пользователям красивые сообщения (модалки, баннеры, карточки) прямо внутри приложения — без обновления сборки. Создай кампанию в Firebase Console, настрой триггер по событию Analytics — и сообщение появится в нужный момент.

---

### 🎯 Цель

Подключить **Firebase In-App Messaging** к приложению FinControl (твой проект Firebase), создать тестовую кампанию в консоли (триггер по событию Analytics или по экрану) и проверить показ in-app сообщения в приложении при срабатывании триггера.

---

### ✅ Ожидаемый результат

- [x] Пакет `firebase_in_app_messaging` подключён
- [x] Кампания создана в Firebase Console → **Engage** → **In-App Messaging** и опубликована
- [x] При выполнении действия-триггера (открытие экрана, событие) сообщение показывается поверх приложения
- [x] В консоли видна статистика кампании (показы, клики)

---

### 📋 Что понадобится

| Что | Зачем |
|-----|-------|
| Выполненная [Часть 0](#часть-0-настройка-проекта-firebase) | Свой проект Firebase, конфиги в проекте, `Firebase.initializeApp()` в коде |
| `firebase_in_app_messaging` | Пакет для Flutter — совместимый с твоей версией `firebase_core` |
| Firebase Console | Доступ к разделу **Engage → In-App Messaging** |
| Часть 3 (желательно) | [Часть 3: Analytics](#часть-3-analytics--события-и-воронки) — In-App Messaging триггерится событиями Analytics |

> ⚠️ **Важно:** сначала выполни [Часть 0](#часть-0-настройка-проекта-firebase) — свой проект, свои конфиги, `Firebase.initializeApp()`. Ключи Sentry/AppMetrica (практики 06–07) — в [STUDENT_ENV.md](../STUDENT_ENV.md), не здесь.

> 💡 **Рекомендация:** выполни [Часть 3: Analytics](#часть-3-analytics--события-и-воронки) перед этой частью — In-App Messaging использует события Analytics как триггеры. Если Analytics настроен, триггеры будут работать надёжнее.

---

### 📝 Пошаговая инструкция

#### Шаг 6.1: Подключение пакета

1. Открой файл `pubspec.yaml` в корне проекта.
2. Добавь зависимость (если её ещё нет):
   ```yaml
   dependencies:
     firebase_in_app_messaging: ^0.8.0  # версия совместимая с твоим firebase_core
   ```
3. Выполни установку:
   ```bash
   flutter pub get
   ```
4. Убедись, что в `main.dart` уже вызван `Firebase.initializeApp()` (по [Части 0](#часть-0-настройка-проекта-firebase)).

> 📌 **Важно:** дополнительный код в приложении чаще всего **не требуется**. После подключения пакета и `Firebase.initializeApp()` In-App Messaging автоматически активируется и показывает кампании, созданные в твоей консоли Firebase.

#### Шаг 6.2: Создание кампании в Firebase Console

1. Открой **Firebase Console** → твой проект.
2. В меню слева найди **Engage** → **In-App Messaging** (или **Messaging** → **In-app**).
3. Нажми **Create campaign** → **In-app message**.
4. **Выбери шаблон сообщения:**

   | Шаблон | Описание | Когда использовать |
   |--------|----------|-------------------|
   | **Modal** | Модальное окно с заголовком, текстом, изображением и кнопкой | Важные сообщения |
   | **Banner (Top/Bottom)** | Неинвазивный баннер, не блокирует UI | Подсказки и советы |
   | **Card** | Карточка с изображением | Промо и поздравления |
   | **Image Only** | Только изображение | Визуальные кампании |

5. Введи заголовок и текст сообщения. Например:
   - **Заголовок:** «Добро пожаловать в FinControl!»
   - **Текст:** «Начните с добавления расхода или проверьте курсы валют в обменнике.»

6. **Targeting** — настрой триггер:
   - **По событию:** выбери событие Analytics (например `screen_view` с параметром экрана, или кастомное событие `exchange_completed`)
   - **По экрану:** укажи имя экрана (если логируешь через Analytics)

7. Установи даты показа и при необходимости лимит показов.

8. Нажми **Publish** — кампания начнёт работать.

> ⚠️ **Кампания не применится мгновенно.** Может пройти несколько минут после публикации. Для быстрого тестирования используй **Test Mode** (см. ниже).

#### Шаг 6.3: Проверка в приложении

1. Запусти приложение на устройстве или эмуляторе.
2. Выполни действие, соответствующее триггеру:
   - Открой нужный экран, **или**
   - Выполни действие, которое генерирует событие Analytics.
3. Сообщение должно появиться поверх приложения в соответствии с выбранным шаблоном.
4. В консоли → In-App Messaging → твоя кампания → посмотри статистику (показы, клики).

#### Шаг 6.4: Test Mode — быстрая проверка без ожидания

Для тестирования без задержки:

1. Получи **Installation ID** своего приложения — добавь временный код:
   ```dart
   import 'package:firebase_core/firebase_core.dart';

   // Вызови где-нибудь при старте (например в main или initState)
   final installationId = await FirebaseInstallations.instance.getId();
   debugPrint('Installation ID: $installationId');
   ```

2. Скопируй ID из консоли отладки (Logcat / Xcode Console).

3. В **Firebase Console** → In-App Messaging → твоя кампания → **Test on Device**.

4. Вставь Installation ID.

5. Сообщение покажется при следующем запуске приложения — **мгновенно**, без задержки.

> 💡 **Подсказка:** Test Mode — лучший способ проверки на экзамене. Не нужно ждать, пока кампания «раскатится».

---

### 🧪 Практические сценарии (Часть 6)

#### Рекомендуемые кампании для FinControl

| Кампания | Шаблон | Триггер | Текст сообщения |
|----------|--------|---------|-----------------|
| Приветствие | Modal | `screen_view` (Welcome) | «Добро пожаловать! Начните с добавления расхода.» |
| Совет в обменнике | Banner (Top) | `screen_view` (Exchange) | «Совет: следите за курсами и создавайте ценовые алерты!» |
| Первая покупка | Card | `portfolio_buy` | «Поздравляем с первой покупкой! Проверьте портфель.» |
| Достижение цели | Modal | `goal_progress_100` | «Цель достигнута! Поставьте новую цель в настройках.» |

#### Сценарий 6.1: Создание приветственной кампании

1. Firebase Console → Engage → In-App Messaging → **Create campaign**.
2. Шаблон: **Modal**.
3. Заголовок: «Добро пожаловать!», текст: «Начни с добавления расхода».
4. Триггер: событие `screen_view` (или `app_open`).
5. **Publish**.
6. Запусти приложение → сообщение появится поверх экрана.

---

### Связь с Firebase Analytics

In-App Messaging работает в тесной связке с **Firebase Analytics**:

| Возможность | Описание |
|-------------|----------|
| **Триггеры** | События Analytics (`screen_view`, кастомные события из Части 3) запускают показ сообщений |
| **Статистика** | Показы и клики кампаний записываются как события Analytics — можно строить воронки |
| **Аудитории** | Условия показа можно привязать к аудиториям Analytics (User Properties) |

> 📌 **Вывод:** чем лучше настроены события Analytics (Часть 3), тем точнее и гибче триггеры In-App Messaging.

---

### 🔍 Проверка (Часть 6)

- [ ] Выполнена [Часть 0](#часть-0-настройка-проекта-firebase)
- [ ] Пакет `firebase_in_app_messaging` добавлен и установлен
- [ ] Кампания создана в Firebase Console → **Engage** → **In-App Messaging** и опубликована
- [ ] Триггер (событие Analytics или имя экрана) настроен и реально срабатывает в приложении
- [ ] In-app сообщение отображается в приложении при срабатывании триггера
- [ ] В консоли видна статистика кампании (показы, клики)

---

### 🎓 Что показать на экзамене (Часть 6)

1. **Firebase Console** → Engage → In-App Messaging → покажи свою кампанию (опубликована, с триггером)
2. **Запусти приложение** → выполни действие-триггер (открой нужный экран или вызови событие)
3. **Покажи сообщение** поверх приложения — модалку, баннер или карточку
4. **В консоли** покажи статистику кампании (показы, клики)
5. **Резюмируй:** «Создал кампанию In-App Messaging, настроил триггер по событию Analytics. При открытии экрана сообщение показывается поверх приложения»

---

### 🛠 Траблшутинг (Часть 6)

| Проблема | Решение |
|----------|---------|
| **Сообщение не показывается** | Убедись, что триггерное событие отправляется в Analytics (проверь DebugView из Части 3). Подожди несколько минут после публикации. Проверь, что приложение подключено к тому же Firebase-проекту |
| **Показывается только один раз** | По умолчанию может быть лимит «один раз на пользователя» — измени настройки кампании, увеличь лимит показов |
| **Сообщение показывается с задержкой** | In-App Messaging кэширует конфиг. Используй **Test Mode** для мгновенной проверки (см. Шаг 6.4) |
| **Триггер не срабатывает** | Проверь, что событие Analytics логируется (DebugView). Имя события в триггере должно совпадать с логируемым |
| **Приложение не подключено к Firebase** | Выполни [Часть 0](#часть-0-настройка-проекта-firebase), проверь конфиги |

Подробнее: [FAQ — Firebase](../FAQ.md#firebase)

---

## Общие ссылки

| Ресурс | Описание |
|--------|----------|
| [Критерии приёмки — Firebase setup](../acceptance-criteria/00-firebase-setup.md) | Чек-лист для экзаменатора (настройка) |
| [Критерии приёмки 10 — Firebase Crashlytics](../acceptance-criteria/10-firebase-crashlytics.md) | Чек-лист для экзаменатора (Crashlytics) |
| [Критерии приёмки 11 — Firebase FCM](../acceptance-criteria/11-firebase-fcm.md) | Чек-лист для экзаменатора (FCM) |
| [Критерии приёмки 12 — Firebase Analytics](../acceptance-criteria/12-firebase-analytics.md) | Чек-лист для экзаменатора (Analytics) |
| [Критерии приёмки 13 — Firebase Remote Config](../acceptance-criteria/13-firebase-remote-config.md) | Чек-лист для экзаменатора (Remote Config) |
| [Критерии приёмки 14 — Firebase Performance](../acceptance-criteria/14-firebase-performance.md) | Чек-лист для экзаменатора (Performance) |
| [Критерии приёмки 15 — Firebase In-App Messaging](../acceptance-criteria/15-firebase-in-app-messaging.md) | Чек-лист для экзаменатора (In-App Messaging) |
| [Список практик и порядок](README.md#список-практик) | Таблица всех практик |
| [FAQ — Firebase](../FAQ.md#firebase) | Частые вопросы по Firebase |
| [STUDENT_ENV.md](../STUDENT_ENV.md) | Ключи Sentry/AppMetrica (практики 06–07) |
| [00-getting-started.md](00-getting-started.md) | Первый запуск проекта (предшествующий шаг) |
| [Официальная документация Flutter Firebase](https://firebase.flutter.dev/docs/overview) | Полный гайд по интеграции |
| [Firebase Console](https://console.firebase.google.com) | Управление проектом |
