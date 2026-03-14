# Критерии приёмки: 09 — Android-дистрибуция

**Практика:** [09 — Android-дистрибуция](../practices/09-android-distribution.md)

Приложение FinControl поставляется из коробки. Для практик Sentry, AppMetrica и Firebase ключи подставляются в указанный файл: `lib/config/student_env.dart` (Sentry, AppMetrica) или конфиги Firebase в проекте. См. [STUDENT_ENV.md](../STUDENT_ENV.md).

## Обязательно

- [ ] Настроено подписание release (keystore, конфигурация в build.gradle.kts).
- [ ] Собран подписанный APK или AAB (`flutter build apk` / `flutter build appbundle`).
- [ ] Сборка загружена в выбранный канал (Google Play Internal testing или Firebase App Distribution).
- [ ] Установка сборки на устройство из этого канала выполнена успешно, приложение запускается.

## Что показать на созвоне

Собранный AAB/APK, загрузка в Internal testing или Firebase App Distribution; установка по ссылке. Подробнее: [exam-and-submission.md](../exam-and-submission.md#3-что-показать-и-что-сказать-на-экзамене-по-блокам).

## Результат

- [ ] **Принято** / **На доработку** (указать, что исправить): _____________________
