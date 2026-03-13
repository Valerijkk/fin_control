# Практики для ручных тестеров — FinControl

Пошаговые инструкции по технологиям. Во всех практиках используется **одно и то же приложение** FinControl (мобильное и при необходимости веб): инвестиционная платформа с курсами валют, обменником и портфелем.

- **Супер подробно, чтобы сразу получилось:** **[practices-step-by-step.md](../practices-step-by-step.md)** — детальные шаги по клонированию, Android Studio, эмулятору, Charles, Sentry, AppMetrica, Firebase и остальному.
- **Частые вопросы и ответы:** **[FAQ.md](../FAQ.md)**.
- **Сдача и экзамен:** что показать на созвоне, чек-листы и пошаговое выполнение — в **[exam-and-submission.md](../exam-and-submission.md)**.

## Список практик

| № | Файл | Технология | Краткое описание |
|---|------|------------|-----------------|
| — | [00-getting-started.md](00-getting-started.md) | **Перед началом** | Клонирование, первый запуск, открытие в Android Studio — выполнить до любых практик |
| 00 | [00-firebase-setup.md](00-firebase-setup.md) | **Firebase: первый шаг** | Регистрация своего проекта, добавление своих конфигов (google-services.json, GoogleService-Info.plist) — **обязательно перед практиками 10–15** |
| 01 | [01-charles.md](01-charles.md) | Charles Proxy | Перехват HTTP/HTTPS трафика мобильного и веб-приложения |
| 02 | [02-proxyman.md](02-proxyman.md) | Proxyman | Снифф трафика FinControl на Android/iOS |
| 03 | [03-android-studio.md](03-android-studio.md) | Android Studio | Установка в эмуляторе, настройка logcat |
| 04 | [04-xcode.md](04-xcode.md) | Xcode | Установка в симуляторе iOS, логи в Console |
| 05 | [05-adb.md](05-adb.md) | ADB | Мануал по возможностям ADB на основе FinControl |
| 06 | [06-sentry.md](06-sentry.md) | Sentry | Настройка проекта, DSN, проверка событий и крашей |
| 07 | [07-appmetrica.md](07-appmetrica.md) | AppMetrica | Заведение приложения, проверка сессий и устройств |
| 08 | [08-testflight.md](08-testflight.md) | TestFlight | Сборка и публикация iOS-приложения в TestFlight |
| 09 | [09-android-distribution.md](09-android-distribution.md) | Android-дистрибуция | Сборка, подпись, Google Play / Firebase App Distribution |
| 10 | [10-firebase-crashlytics.md](10-firebase-crashlytics.md) | Firebase Crashlytics | Стабильность релиза, отчёты о падениях |
| 11 | [11-firebase-fcm.md](11-firebase-fcm.md) | Firebase FCM | Push-уведомления, токен, тестовое сообщение |
| 12 | [12-firebase-analytics.md](12-firebase-analytics.md) | Firebase Analytics | События и воронки |
| 13 | [13-firebase-remote-config.md](13-firebase-remote-config.md) | Firebase Remote Config | Фичефлаги и rollout |
| 14 | [14-firebase-performance.md](14-firebase-performance.md) | Firebase Performance | Регресс по скорости, трейсы |
| 15 | [15-firebase-in-app-messaging.md](15-firebase-in-app-messaging.md) | Firebase In-App Messaging | In-app сообщения и кампании |

## Порядок прохождения

Рекомендуемый порядок для учеников:

1. **Инфраструктура**: 03 (Android Studio), 04 (Xcode), 05 (ADB) — установка приложения и логи.
2. **Снифф трафика**: 01 (Charles), 02 (Proxyman) — перехват запросов к API курсов.
3. **Мониторинг**: 06 (Sentry), 07 (AppMetrica) — краши и аналитика.
4. **Дистрибуция**: 08 (TestFlight), 09 (Android) — сборки для тестеров.
5. **Firebase**: сначала **[00-firebase-setup.md](00-firebase-setup.md)** — каждый регистрирует свой проект и вставляет свои конфиги; затем практики 10–15 по модулям.
