# 📚 Практики — FinControl

> **FinControl** — учебное Flutter-приложение для практик по мобильному тестированию. Одно приложение на все 11 практик: клонируй репозиторий, выполни начальную настройку — и вперёд. Каждая практика — пошаговая инструкция от «открой консоль» до «покажи на экзамене».

---

## 🚀 Быстрый старт

1. Клонируй репозиторий и запусти приложение → [00-getting-started.md](00-getting-started.md)
2. Приложение работает **из коробки**: приветствие → главный экран с навигацией (Список, Обменник, Акции, Портфель, Статистика)
3. Для практик 06–07 (Sentry, AppMetrica) — вставь ключи в [STUDENT_ENV.md](../STUDENT_ENV.md) → `lib/config/student_env.dart`
4. Для практики 10 (Firebase) — создай свой проект и пройди все модули по [10-firebase.md](10-firebase.md)

---

## 📋 Список всех практик

| № | Практика | Технология | Краткое описание | Сложность |
|:-:|----------|------------|------------------|:---------:|
| — | [00-getting-started.md](00-getting-started.md) | **Перед началом** | Клонирование, первый запуск, открытие в Android Studio | 🟢 базовая |

### 🔌 Блок 1: Инструменты и инфраструктура

| № | Практика | Технология | Краткое описание | Сложность |
|:-:|----------|------------|------------------|:---------:|
| 01 | [01-charles.md](01-charles.md) | Charles Proxy | Перехват HTTP/HTTPS, Breakpoints, Map Remote/Local, Rewrite, Throttling | 🟡 средняя |
| 02 | [02-proxyman.md](02-proxyman.md) | Proxyman | Снифф трафика, Breakpoint, Map Local, Scripting, Network Conditions, Diff | 🟡 средняя |
| 03 | [03-android-studio.md](03-android-studio.md) | Android Studio | Эмулятор, Logcat, Layout Inspector, App Inspection (DB), Profiler | 🟢 базовая |
| 04 | [04-xcode.md](04-xcode.md) | Xcode | Симулятор iOS, Console, Instruments, View Debugger, Network Link Conditioner | 🟢 базовая |
| 05 | [05-adb.md](05-adb.md) | ADB | install, logcat, screencap, screenrecord, monkey, разрешения, Wi-Fi debug | 🟡 средняя |

### 📊 Блок 2: Мониторинг и аналитика

| № | Практика | Технология | Краткое описание | Сложность |
|:-:|----------|------------|------------------|:---------:|
| 06 | [06-sentry.md](06-sentry.md) | Sentry | DSN, события, breadcrumbs, контекст пользователя, Performance, Alerts | 🟡 средняя |
| 07 | [07-appmetrica.md](07-appmetrica.md) | AppMetrica | API Key, сессии, устройства, кастомные события, профили, воронки | 🟡 средняя |

### 📦 Блок 3: Дистрибуция

| № | Практика | Технология | Краткое описание | Сложность |
|:-:|----------|------------|------------------|:---------:|
| 08 | [08-testflight.md](08-testflight.md) | TestFlight | Архив, подписание, загрузка в App Store Connect, раздача тестерам | 🔴 продвинутая |
| 09 | [09-android-distribution.md](09-android-distribution.md) | Android-дистрибуция | Keystore, подпись, AAB/APK, Google Play Internal / Firebase App Distribution | 🔴 продвинутая |

### 🔥 Блок 4: Firebase

| № | Практика | Технология | Краткое описание | Сложность |
|:-:|----------|------------|------------------|:---------:|
| 10 | [10-firebase.md](10-firebase.md) | Firebase (полный гайд) | Setup, Crashlytics, FCM, Analytics, Remote Config, Performance, In-App Messaging | 🟡 средняя |

---

## 🗺 Рекомендуемый порядок прохождения

```
Перед началом
  └── 00-getting-started.md

Блок 1: Инструменты               Блок 2: Мониторинг
  ├── 03 Android Studio              ├── 06 Sentry
  ├── 04 Xcode                       └── 07 AppMetrica
  ├── 05 ADB
  ├── 01 Charles                   Блок 3: Дистрибуция
  └── 02 Proxyman                    ├── 08 TestFlight
                                     └── 09 Android
Блок 4: Firebase
  └── 10 Firebase (полный гайд: setup → Crashlytics → FCM → Analytics → Remote Config → Performance → In-App Messaging)
```

### Подробнее по шагам

| Этап | Практики | Что получишь |
|------|----------|-------------|
| **1. Старт** | [00-getting-started.md](00-getting-started.md) | Работающее приложение на эмуляторе |
| **2. Инфраструктура** | 03 → 04 → 05 | Эмулятор, логи, ADB-команды — базовый инструментарий |
| **3. Снифф трафика** | 01 → 02 | Перехват и модификация HTTP-запросов к API курсов |
| **4. Мониторинг** | 06 → 07 | Краши в Sentry, аналитика в AppMetrica |
| **5. Дистрибуция** | 08 → 09 | Сборка и раздача через TestFlight / Google Play |
| **6. Firebase** | 10 (полный гайд) | Setup, Crashlytics, пуши, аналитика, Remote Config, Performance, In-App Messaging |

> 💡 **Совет:** блоки 1–3 можно проходить параллельно. Блок 4 (Firebase) — по порядку частей в `10-firebase.md`.

---

## 🔑 Куда вставлять ключи и конфиги

| Что | Куда | Практики |
|-----|------|----------|
| **Sentry DSN** | [STUDENT_ENV.md](../STUDENT_ENV.md) → `lib/config/student_env.dart` | 06 |
| **AppMetrica API Key** | [STUDENT_ENV.md](../STUDENT_ENV.md) → `lib/config/student_env.dart` | 07 |
| **Firebase конфиги** | `google-services.json` + `GoogleService-Info.plist` в проект | 10 |

> 📌 Для Sentry и AppMetrica достаточно вставить ключ в один файл и перезапустить. Для Firebase — следуй [10-firebase.md](10-firebase.md).

---

## 📖 Полезные ссылки

| Ресурс | Описание |
|--------|----------|
| [practices-step-by-step.md](../practices-step-by-step.md) | Пошаговая карта прохождения всех практик |
| [STUDENT_ENV.md](../STUDENT_ENV.md) | Инструкция по ключам Sentry/AppMetrica |
| [FAQ.md](../FAQ.md) | Вопросы и ответы по частым проблемам |
| [exam-and-submission.md](../exam-and-submission.md) | Что показать на созвоне, чек-листы для сдачи |
| [acceptance-criteria/README.md](../acceptance-criteria/README.md) | Критерии приёмки для экзаменатора |
