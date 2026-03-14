# Критерии приёмки: 10 — Firebase Crashlytics

**Практика:** [10 — Firebase Crashlytics](../practices/10-firebase-crashlytics.md)

Приложение FinControl поставляется из коробки. Для Firebase используются конфиги проекта (`google-services.json` / `GoogleService-Info.plist`); ключи не хранятся в коде. См. [00-firebase-setup](00-firebase-setup.md), [STUDENT_ENV.md](../STUDENT_ENV.md).

## Обязательно

- [ ] Выполнена практика 00-firebase-setup (свой проект, конфиги, `Firebase.initializeApp()`).
- [ ] В проект добавлен пакет `firebase_crashlytics`, в `main.dart` настроен перехват Flutter-ошибок и запись в Crashlytics.
- [ ] Вызван тестовый краш (кнопка в приложении или `FirebaseCrashlytics.instance.crash()`).
- [ ] Приложение перезапущено (для отправки отчёта после краша).
- [ ] В Firebase Console → Crashlytics отображается отчёт о краше (стектрейс, устройство).

## Что показать на созвоне

Тестовый краш в приложении; отчёт в Firebase Console → Crashlytics. Подробнее: [exam-and-submission.md](../exam-and-submission.md#3-что-показать-и-что-сказать-на-экзамене-по-блокам).

## Результат

- [ ] **Принято** / **На доработку** (указать, что исправить): _____________________
