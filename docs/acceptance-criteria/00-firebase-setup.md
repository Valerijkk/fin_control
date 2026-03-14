# Критерии приёмки: 00 — Firebase setup

**Практика:** [00 — Firebase setup](../practices/00-firebase-setup.md)

Приложение FinControl поставляется из коробки. Для Firebase ключи и конфиги подставляются в проект: `google-services.json` (Android) и `GoogleService-Info.plist` (iOS); не коммитить чужие конфиги в репозиторий. См. [STUDENT_ENV.md](../STUDENT_ENV.md).

## Обязательно

- [ ] В Firebase Console создан проект (свой аккаунт Firebase).
- [ ] Добавлено приложение Android: указан package name из FinControl.
- [ ] Файл `google-services.json` скачан и размещён в `android/app/`.
- [ ] При необходимости добавлено приложение iOS и `GoogleService-Info.plist` в `ios/Runner/`.
- [ ] В `pubspec.yaml` добавлена зависимость `firebase_core`.
- [ ] В `main.dart` до `runApp()` выполняется `Firebase.initializeApp()`.
- [ ] Приложение запускается без ошибки инициализации Firebase (при наличии конфигов).

## Желательно

- [ ] В корне проекта нет чужих конфигов (не коммитить чужие google-services.json / plist в общий репозиторий без необходимости).

## Что показать на созвоне

В консоли Firebase — добавленные приложения Android/iOS; в проекте — файлы `google-services.json` / `GoogleService-Info.plist`. Приложение запускается без ошибки инициализации. Подробнее: [exam-and-submission.md](../exam-and-submission.md#3-что-показать-и-что-сказать-на-экзамене-по-блокам).

## Результат

- [ ] **Принято** / **На доработку** (указать, что исправить): _____________________
