# 🔗 Практики (ссылки)

> Детальные пошаговые практики лежат в [**docs/practices/**](../../practices/).
> Здесь — ссылки для быстрого перехода из тестовой документации.

---

## 🚀 Запуск

Приложение **одно**, запускается **из коробки**. Для проверки метрик достаточно подставить ключи:

| Сервис | Где настраивать | Подробности |
|--------|----------------|-------------|
| **Sentry и AppMetrica** | [`lib/config/student_env.dart`](../../../lib/config/student_env.dart) | [STUDENT_ENV.md](../../STUDENT_ENV.md) |
| **Firebase** | Конфиги проекта по инструкции | [10-firebase.md](../../practices/10-firebase.md) |

> 📖 **[Оглавление практик и порядок прохождения](../../practices/README.md)**
> 📋 **Критерии приёмки по каждой практике:** [acceptance-criteria/README.md](../../acceptance-criteria/README.md)

---

## 📋 Список практик

### 🔌 Блок 1: Инструменты и инфраструктура

| № | Практика | Файл |
|:-:|----------|------|
| — | Перед началом | [00-getting-started.md](../../practices/00-getting-started.md) |
| 01 | Charles Proxy | [01-charles.md](../../practices/01-charles.md) |
| 02 | Proxyman | [02-proxyman.md](../../practices/02-proxyman.md) |
| 03 | Android Studio | [03-android-studio.md](../../practices/03-android-studio.md) |
| 04 | Xcode | [04-xcode.md](../../practices/04-xcode.md) |
| 05 | ADB | [05-adb.md](../../practices/05-adb.md) |

### 📊 Блок 2: Мониторинг и аналитика

| № | Практика | Файл |
|:-:|----------|------|
| 06 | Sentry | [06-sentry.md](../../practices/06-sentry.md) |
| 07 | AppMetrica | [07-appmetrica.md](../../practices/07-appmetrica.md) |

### 📦 Блок 3: Дистрибуция

| № | Практика | Файл |
|:-:|----------|------|
| 08 | TestFlight | [08-testflight.md](../../practices/08-testflight.md) |
| 09 | Android-дистрибуция | [09-android-distribution.md](../../practices/09-android-distribution.md) |

### 🔥 Блок 4: Firebase (все модули в одном файле)

| № | Практика | Файл |
|:-:|----------|------|
| 10 | Firebase (Setup, Crashlytics, FCM, Analytics, Remote Config, Performance, In-App Messaging) | [10-firebase.md](../../practices/10-firebase.md) |

> 💡 Firebase-практика объединяет все модули в один последовательный гайд: setup → Crashlytics → FCM → Analytics → Remote Config → Performance → In-App Messaging.
