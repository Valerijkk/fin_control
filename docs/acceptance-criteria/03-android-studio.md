# Критерии приёмки: 03 — Android Studio

**Практика:** [03 — Android Studio](../practices/03-android-studio.md)

Приложение FinControl поставляется из коробки. Для практик Sentry, AppMetrica и Firebase ключи подставляются в указанный файл: `lib/config/student_env.dart` (Sentry, AppMetrica) или конфиги Firebase в проекте. См. [STUDENT_ENV.md](../STUDENT_ENV.md).

## Обязательно

- [ ] Создан и запущен AVD (эмулятор) в Android Studio.
- [ ] Приложение FinControl установлено в эмулятор (через `flutter run` или установку APK).
- [ ] Приложение запускается и отображает приветственный экран или Shell.
- [ ] Открыт Logcat, настроен фильтр по тегу `[FinControl]` или по пакету приложения.
- [ ] При переходах по экранам (Список → Обменник → Портфель) в Logcat появляются логи с тегом `[FinControl]`.

## Желательно

- [ ] Ученик открыл **Layout Inspector** и показал иерархию виджетов работающего приложения.
- [ ] Ученик открыл **App Inspection → Database Inspector** и показал таблицы SQLite (expenses, portfolio_holdings и др.).
- [ ] Ученик открыл **Profiler** (Memory или Network) и показал базовые метрики.
- [ ] Ученик использовал **Device File Explorer** для просмотра файлов приложения.

## Что показать на созвоне

Эмулятор с запущенным FinControl, Logcat с фильтром по тегу `[FinControl]` — логи при переходе по экранам. Layout Inspector или Database Inspector (если продемонстрировано). Подробнее: [exam-and-submission.md](../exam-and-submission.md#3-что-показать-и-что-сказать-на-экзамене-по-блокам).

## Результат

- [ ] **Принято** / **На доработку** (указать, что исправить): _____________________
