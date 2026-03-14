# Критерии приёмки — для экзаменатора

Папка для приёмки практик по **одному приложению FinControl**: чек-листы по каждой практике, перечень заложенных багов (задание под звёздочкой) и что нужно показать на созвоне.

**Приложение поставляется из коробки.** Метрики и Firebase подключаются только подстановкой токенов в указанный файл: Sentry и AppMetrica — в `lib/config/student_env.dart`; Firebase — конфиги проекта (`google-services.json` / `GoogleService-Info.plist`). Подробнее: [STUDENT_ENV.md](../STUDENT_ENV.md).

---

## Для экзаменатора

| Документ | Назначение |
|----------|------------|
| **[bugs-dlya-ekzamenatora.md](bugs-dlya-ekzamenatora.md)** | 5 заложенных багов разной сложности: где искать, как воспроизвести, как исправить. Только для преподавателя. |
| **[../exam-and-submission.md](../exam-and-submission.md)** | Что показать на созвоне по всем практикам, чек-лист перед созвоном, типичные вопросы экзаменатора. |

---

## Как пользоваться чек-листами практик

1. Практика выполняется по инструкции из **[docs/practices/](../practices/)** (в каждом файле критериев есть ссылка на соответствующую практику).
2. Проверяющий открывает соответствующий файл критериев (например `01-charles.md`) и проходит по чек-листу (единый стиль: секции «Обязательно», «Желательно», «Что показать на созвоне», «Результат»).
3. Все пункты с пометкой «Обязательно» должны быть выполнены; при наличии «Желательно» — по усмотрению приёмки.
4. В каждом файле критериев есть блок **«Что показать на созвоне»** — краткий ориентир для демо; подробные сценарии в [exam-and-submission.md](../exam-and-submission.md).

**Безопасность:** по практикам с ключами (Sentry, AppMetrica, Firebase) ученик должен понимать, что реальные DSN/API Key и конфиги с секретами не коммитятся в репозиторий; ключи хранятся только в `student_env.dart` (или аналоге) локально. По Charles/Proxyman — перехват HTTPS только в учебной среде, с пониманием рисков установки стороннего CA. Подробнее: [FAQ — Безопасность ключей и данных](../FAQ.md#безопасность-ключей-и-данных), [STUDENT_ENV.md](../STUDENT_ENV.md).

**UX:** краткие критерии по подписям, обратной связи и единообразию интерфейса описаны в [PRD](../business/PRD_fin_control.md) (раздел 4.3); детальное ожидаемое поведение UI по фичам — в [testing/features](../testing/features/) (раздел «Ожидаемое поведение UI» в каждом файле фичи).

---

## Список критериев по практикам

| № | Файл | Практика |
|---|------|----------|
| 00 | [00-firebase-setup.md](00-firebase-setup.md) | Firebase: первый шаг |
| 01 | [01-charles.md](01-charles.md) | Charles Proxy |
| 02 | [02-proxyman.md](02-proxyman.md) | Proxyman |
| 03 | [03-android-studio.md](03-android-studio.md) | Android Studio |
| 04 | [04-xcode.md](04-xcode.md) | Xcode |
| 05 | [05-adb.md](05-adb.md) | ADB |
| 06 | [06-sentry.md](06-sentry.md) | Sentry |
| 07 | [07-appmetrica.md](07-appmetrica.md) | AppMetrica |
| 08 | [08-testflight.md](08-testflight.md) | TestFlight |
| 09 | [09-android-distribution.md](09-android-distribution.md) | Android-дистрибуция |
| 10 | [10-firebase-crashlytics.md](10-firebase-crashlytics.md) | Firebase Crashlytics |
| 11 | [11-firebase-fcm.md](11-firebase-fcm.md) | Firebase FCM |
| 12 | [12-firebase-analytics.md](12-firebase-analytics.md) | Firebase Analytics |
| 13 | [13-firebase-remote-config.md](13-firebase-remote-config.md) | Firebase Remote Config |
| 14 | [14-firebase-performance.md](14-firebase-performance.md) | Firebase Performance |
| 15 | [15-firebase-in-app-messaging.md](15-firebase-in-app-messaging.md) | Firebase In-App Messaging |
