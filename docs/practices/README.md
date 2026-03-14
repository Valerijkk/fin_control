# Практики — FinControl

Теория и пошаговые инструкции по технологиям. **Одно приложение** FinControl (мобильное и при необходимости веб) — запускается **из коробки**: клонируй репозиторий, выполни [00-getting-started.md](00-getting-started.md), и приложение уже работает (приветствие → главный экран с навигацией: Список, Обменник, Акции, Портфель, Статистика).

**Метрики и Firebase — только подставить токены/конфиги:**
- **Sentry и AppMetrica (практики 06–07):** вставить DSN / API Key в один файл — [STUDENT_ENV.md](../STUDENT_ENV.md) → `lib/config/student_env.dart` — сохранить и перезапустить приложение; больше ничего не нужно.
- **Firebase (практики 10–15):** следовать [00-firebase-setup.md](00-firebase-setup.md) (свой проект, свои `google-services.json` и `GoogleService-Info.plist` в проект), затем практики 10–15 по шагам; конфиги — в проект, остальное из коробки.

В каждой практике: **цель** в начале, **ожидаемый результат** в конце, пошаговые шаги без пропусков (что установить, что открыть, что нажать), блок **Проверка**, при необходимости **Траблшутинг**, ссылки на [STUDENT_ENV.md](../STUDENT_ENV.md) (где нужны ключи), [FAQ.md](../FAQ.md) и [критерии приёмки](../acceptance-criteria/README.md).

- **Пошагово:** [practices-step-by-step.md](../practices-step-by-step.md) — карта и ссылки на каждую практику.
- **Ключи Sentry/AppMetrica (практики 06–07):** только [STUDENT_ENV.md](../STUDENT_ENV.md) → `lib/config/student_env.dart`; перезапуск — и всё.
- **Вопросы и ответы:** [FAQ.md](../FAQ.md).
- **Сдача:** что показать на созвоне, чек-листы — [exam-and-submission.md](../exam-and-submission.md).
- **Критерии приёмки:** чек-листы для экзаменатора — [acceptance-criteria/README.md](../acceptance-criteria/README.md).

---

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

---

## Порядок прохождения

Рекомендуемый порядок (совпадает с [practices-step-by-step.md](../practices-step-by-step.md)):

1. **Перед началом**: [00-getting-started.md](00-getting-started.md) — клонирование, первый запуск, Android Studio.
2. **Инфраструктура**: 03 (Android Studio), 04 (Xcode), 05 (ADB) — установка приложения и логи.
3. **Снифф трафика**: 01 (Charles), 02 (Proxyman) — перехват запросов к API курсов.
4. **Мониторинг**: 06 (Sentry), 07 (AppMetrica) — краши и аналитика.
5. **Дистрибуция**: 08 (TestFlight), 09 (Android) — сборки.
6. **Firebase**: сначала **[00-firebase-setup.md](00-firebase-setup.md)** — каждый регистрирует свой проект и вставляет свои конфиги; затем практики 10–15 по модулям.
