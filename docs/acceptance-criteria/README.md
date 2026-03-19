# 📋 Критерии приёмки — для экзаменатора

> Чек-листы по каждой практике **одного приложения FinControl**: что проверить, что показать на созвоне, перечень заложенных багов (задание со звёздочкой).

---

## 🚀 О приложении

Приложение поставляется **из коробки**. Метрики и Firebase подключаются подстановкой токенов:

| Сервис | Где настраивать | Подробности |
|--------|----------------|-------------|
| **Sentry и AppMetrica** | `lib/config/student_env.dart` | [STUDENT_ENV.md](../STUDENT_ENV.md) |
| **Firebase** | Конфиги проекта (`google-services.json` / `GoogleService-Info.plist`) | [10-firebase.md](../practices/10-firebase.md) |

---

## 👨‍🏫 Для экзаменатора

| Документ | Назначение |
|----------|------------|
| 🐛 **[bugs-dlya-ekzamenatora.md](bugs-dlya-ekzamenatora.md)** | 5 заложенных багов разной сложности: где искать, как воспроизвести, как исправить. **Только для преподавателя** |
| 🎓 **[../exam-and-submission.md](../exam-and-submission.md)** | Что показать на созвоне по всем практикам, чек-лист, типичные вопросы экзаменатора |

---

## 📖 Как пользоваться чек-листами

1. Практика выполняется по инструкции из **[docs/practices/](../practices/)** (в каждом файле критериев есть ссылка на практику)
2. Проверяющий открывает файл критериев (например `01-charles.md`) и проходит по чек-листу
3. Все пункты с пометкой **«Обязательно»** должны быть выполнены; **«Желательно»** — по усмотрению
4. В каждом файле есть блок **«Что показать на созвоне»** — краткий ориентир для демо

> 🔒 **Безопасность:** по практикам с ключами (Sentry, AppMetrica, Firebase) ученик должен понимать, что реальные DSN/API Key не коммитятся в репозиторий. Подробнее: [FAQ](../FAQ.md), [STUDENT_ENV.md](../STUDENT_ENV.md).

> 🎨 **UX:** краткие критерии по UI описаны в [PRD](../business/PRD_fin_control.md) (раздел 4.3); детальное поведение — в [testing/features](../testing/features/).

---

## 📋 Список критериев по практикам

### 🔌 Блок 1: Инструменты и инфраструктура

| № | Файл | Практика |
|:-:|------|----------|
| 00 | [00-firebase-setup.md](00-firebase-setup.md) | Firebase: первый шаг |
| 01 | [01-charles.md](01-charles.md) | Charles Proxy |
| 02 | [02-proxyman.md](02-proxyman.md) | Proxyman |
| 03 | [03-android-studio.md](03-android-studio.md) | Android Studio |
| 04 | [04-xcode.md](04-xcode.md) | Xcode |
| 05 | [05-adb.md](05-adb.md) | ADB |

### 📊 Блок 2: Мониторинг и аналитика

| № | Файл | Практика |
|:-:|------|----------|
| 06 | [06-sentry.md](06-sentry.md) | Sentry |
| 07 | [07-appmetrica.md](07-appmetrica.md) | AppMetrica |

### 📦 Блок 3: Дистрибуция

| № | Файл | Практика |
|:-:|------|----------|
| 08 | [08-testflight.md](08-testflight.md) | TestFlight |
| 09 | [09-android-distribution.md](09-android-distribution.md) | Android-дистрибуция |

### 🔥 Блок 4: Firebase

> 📌 **Практика Firebase** теперь объединена в один файл — [10-firebase.md](../practices/10-firebase.md).
> Критерии приёмки по модулям Firebase остаются **по отдельности** (файлы 10–15):

| № | Файл | Модуль Firebase |
|:-:|------|-----------------|
| 10 | [10-firebase-crashlytics.md](10-firebase-crashlytics.md) | Crashlytics |
| 11 | [11-firebase-fcm.md](11-firebase-fcm.md) | FCM (Push-уведомления) |
| 12 | [12-firebase-analytics.md](12-firebase-analytics.md) | Analytics |
| 13 | [13-firebase-remote-config.md](13-firebase-remote-config.md) | Remote Config |
| 14 | [14-firebase-performance.md](14-firebase-performance.md) | Performance |
| 15 | [15-firebase-in-app-messaging.md](15-firebase-in-app-messaging.md) | In-App Messaging |
