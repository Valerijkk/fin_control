# Практики FinControl — пошагово (оглавление)

Подробные пошаговые инструкции разнесены по файлам в папке [practices](practices/). Здесь — карта: с чего начать и куда перейти по каждой практике.

Если что-то не получилось — смотри [FAQ](FAQ.md).

**Переменные под себя (Sentry, AppMetrica):** нажми и открой файл → [**lib/config/student_env.dart**](../lib/config/student_env.dart) — вставь туда ключи по практикам (в файле капсом подписано, что куда). Без переменных приложение работает с локальной БД; заполняешь поэтапно (06 → DSN, 07 → API Key) — после каждого перезапуска всё работает корректно. Подробнее: [STUDENT_ENV.md](STUDENT_ENV.md).

---

## 1. Перед началом любых практик

**Клонирование, первый запуск, открытие в Android Studio** — всё в одном файле:

→ **[practices/00-getting-started.md](practices/00-getting-started.md)**

---

## 2. Практики по шагам (детально)

| Практика | Файл с пошаговой инструкцией |
|----------|------------------------------|
| 03 Android Studio (эмулятор, Logcat) | [practices/03-android-studio.md](practices/03-android-studio.md) |
| 01 Charles (перехват трафика) | [practices/01-charles.md](practices/01-charles.md) |
| 02 Proxyman | [practices/02-proxyman.md](practices/02-proxyman.md) |
| 05 ADB (команды, логи, скриншоты) | [practices/05-adb.md](practices/05-adb.md) |
| 06 Sentry (события и краши) | [practices/06-sentry.md](practices/06-sentry.md) |
| 07 AppMetrica | [practices/07-appmetrica.md](practices/07-appmetrica.md) |
| 00 Firebase (первый шаг перед 10–15) | [practices/00-firebase-setup.md](practices/00-firebase-setup.md) |
| 04 Xcode | [practices/04-xcode.md](practices/04-xcode.md) |
| 08 TestFlight | [practices/08-testflight.md](practices/08-testflight.md) |
| 09 Android-дистрибуция | [practices/09-android-distribution.md](practices/09-android-distribution.md) |
| 10–15 Firebase (Crashlytics, FCM, Analytics и др.) | [practices/10-firebase-crashlytics.md](practices/10-firebase-crashlytics.md) … [15-firebase-in-app-messaging.md](practices/15-firebase-in-app-messaging.md) |

Полный список и порядок прохождения: [practices/README.md](practices/README.md).

---

## 3. Чек-лист перед сдачей

- [ ] Проект клонирован, `flutter pub get` и `flutter run` выполняются без ошибок.
- [ ] В Android Studio открыта **корневая** папка проекта (где `pubspec.yaml`), а не папка `android/`.
- [ ] По каждой сдаваемой практике: выполнены все шаги из соответствующего файла в [practices/](practices/) и из этого документа.
- [ ] Можешь за 2–5 минут показать результат: запрос в Charles, логи в Logcat, событие в Sentry, сессию в AppMetrica и т.д.
- [ ] Можешь одним-двумя предложениями объяснить, что делал в практике.

---

## 4. Ссылки

- [Список практик и порядок прохождения](practices/README.md)
- [Переменные Sentry/AppMetrica (практики 06–07)](STUDENT_ENV.md) — куда вставлять DSN и API Key
- [Что показать на экзамене и чек-листы](exam-and-submission.md)
- [Критерии приёмки для экзаменатора](acceptance-criteria/README.md)
- [Частые вопросы и ответы](FAQ.md)
