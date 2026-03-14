# Документация FinControl — карта по папкам

**FinControl** — одно Flutter-приложение для всех мобильных и веб-практик (учёт расходов, обменник, портфель, интеграции). Всё настроено **из коробки**; метрики и Firebase — только подставить **токены в указанный файл** [lib/config/student_env.dart](../lib/config/student_env.dart) (подробнее: [STUDENT_ENV.md](STUDENT_ENV.md)) и следовать инструкциям. Документация разложена по папкам: критерии приёмки, практики, техническая и бизнесовая документация, тестовая. В корне `docs/` — общие точки входа.

---

## Папки

| Папка | Назначение |
|-------|------------|
| **[acceptance-criteria/](acceptance-criteria/)** | Для экзаменатора: чек-листы по каждой практике, перечень заложенных багов (задание под звёздочкой), что нужно показать на созвоне. См. также [exam-and-submission.md](exam-and-submission.md). |
| **[practices/](practices/)** | Практики по шагам: перед началом ([00-getting-started](practices/00-getting-started.md)), 01–09 (Charles, Proxyman, Android Studio, Xcode, ADB, Sentry, AppMetrica, TestFlight, Android-дистрибуция), [00 Firebase setup](practices/00-firebase-setup.md), 10–15 Firebase (Crashlytics, FCM, Analytics и др.). Отдельный файл на каждую практику; однозначный порядок — в [practices-step-by-step.md](practices-step-by-step.md). |
| **[technical/](technical/)** | Архитектура, модели данных, API-спецификация, запуск в Android Studio. |
| **[business/](business/)** | PRD, майлстоуны, бизнес- и функциональные требования. |
| **[testing/](testing/)** | Тестовая документация: фичи (требования по экранам), тест-кейсы; ссылки на практики ведут в [practices/](practices/) — один источник пошаговых инструкций. |

---

## С чего начать

| Документ | Для чего |
|----------|----------|
| **[practices-step-by-step.md](practices-step-by-step.md)** | Оглавление пошагового гайда: ссылки на «перед началом» и на каждую практику. Читать и выполнять по шагам. |
| **[practices/00-getting-started.md](practices/00-getting-started.md)** | Клонирование, первый запуск, как открывать проект в Android Studio. |
| **[FAQ.md](FAQ.md)** | Ответы на частые вопросы: ошибки в Android Studio, Charles не видит трафик, DSN/API Key, курсы не грузятся, тесты, Firebase, сдача. |
| **[STUDENT_ENV.md](STUDENT_ENV.md)** | Файл переменных для ученика: куда вставлять DSN/API Key по практикам, режимы запуска (локальная БД без ключей / полный запуск с ключами). |

---

## Практики и сдача

| Документ | Для чего |
|----------|----------|
| **[practices/README.md](practices/README.md)** | Список всех практик с единой нумерацией (см. таблицу ниже) и рекомендуемый порядок прохождения. |
| **[practices-step-by-step.md](practices-step-by-step.md)** | Карта пошагового гайда: порядок выполнения и ссылки на каждую практику. |
| **[exam-and-submission.md](exam-and-submission.md)** | Сдача и экзамен: что от тебя хотят, что показать и что сказать по каждой практике, чек-лист перед созвоном, типичные вопросы экзаменатора. |
| **[acceptance-criteria/README.md](acceptance-criteria/README.md)** | Критерии приёмки для преподавателя + баги для задания под звёздочкой. Полезно пройти самому перед сдачей. |

### Единая нумерация практик

Нумерация по именам файлов в [practices/](practices/); порядок выполнения — в [practices-step-by-step.md](practices-step-by-step.md).

| № | Практика | Файл |
|---|----------|------|
| — | Перед началом | [00-getting-started.md](practices/00-getting-started.md) |
| 00 | Firebase: первый шаг | [00-firebase-setup.md](practices/00-firebase-setup.md) |
| 01 | Charles | [01-charles.md](practices/01-charles.md) |
| 02 | Proxyman | [02-proxyman.md](practices/02-proxyman.md) |
| 03 | Android Studio | [03-android-studio.md](practices/03-android-studio.md) |
| 04 | Xcode | [04-xcode.md](practices/04-xcode.md) |
| 05 | ADB | [05-adb.md](practices/05-adb.md) |
| 06 | Sentry | [06-sentry.md](practices/06-sentry.md) |
| 07 | AppMetrica | [07-appmetrica.md](practices/07-appmetrica.md) |
| 08 | TestFlight | [08-testflight.md](practices/08-testflight.md) |
| 09 | Android-дистрибуция | [09-android-distribution.md](practices/09-android-distribution.md) |
| 10 | Firebase Crashlytics | [10-firebase-crashlytics.md](practices/10-firebase-crashlytics.md) |
| 11 | Firebase FCM | [11-firebase-fcm.md](practices/11-firebase-fcm.md) |
| 12 | Firebase Analytics | [12-firebase-analytics.md](practices/12-firebase-analytics.md) |
| 13 | Firebase Remote Config | [13-firebase-remote-config.md](practices/13-firebase-remote-config.md) |
| 14 | Firebase Performance | [14-firebase-performance.md](practices/14-firebase-performance.md) |
| 15 | Firebase In-App Messaging | [15-firebase-in-app-messaging.md](practices/15-firebase-in-app-messaging.md) |

---

## Разработка и тестирование

| Раздел | Где смотреть |
|--------|--------------|
| Архитектура, API, модели данных, Android Studio | [technical/](technical/) |
| PRD, майлстоуны, требования | [business/](business/) |
| Фичи, тест-кейсы, ссылки на практики | [testing/](testing/) |

---

## Корень проекта

- **Корневой [../README.md](../README.md)** — обзор проекта, возможности, быстрый старт, структура, тесты, траблшутинг.

**Итого:** для прохождения практик и сдачи в первую очередь нужны **practices-step-by-step.md**, **practices/00-getting-started.md**, **STUDENT_ENV.md** (куда вставлять DSN/API Key — единственное место для токенов Sentry/AppMetrica), **FAQ.md** и **exam-and-submission.md**. Остальное — по необходимости (конкретная практика, критерии приёмки, техническая/бизнесовая/тестовая документация).

---

## Ссылки по разделам

- **Практики (порядок и шаги):** [practices-step-by-step.md](practices-step-by-step.md), [practices/](practices/), [practices/README.md](practices/README.md)
- **Критерии приёмки и сдача:** [acceptance-criteria/](acceptance-criteria/), [acceptance-criteria/README.md](acceptance-criteria/README.md), [exam-and-submission.md](exam-and-submission.md)
- **Техническая документация:** [technical/](technical/)
- **Бизнес и требования:** [business/](business/)
- **Тестирование:** [testing/](testing/)
- **Переменные и токены:** [STUDENT_ENV.md](STUDENT_ENV.md) · **Вопросы и ответы:** [FAQ.md](FAQ.md)
