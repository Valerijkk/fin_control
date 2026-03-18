# Критерии приёмки: 04 — Xcode

**Практика:** [04 — Xcode](../practices/04-xcode.md)

Приложение FinControl поставляется из коробки. Для практик Sentry, AppMetrica и Firebase ключи подставляются в указанный файл: `lib/config/student_env.dart` (Sentry, AppMetrica) или конфиги Firebase в проекте. См. [STUDENT_ENV.md](../STUDENT_ENV.md).

## Обязательно

- [ ] Открыт именно `ios/Runner.xcworkspace` (не .xcodeproj), выбраны схема Runner и симулятор.
- [ ] FinControl собран и установлен в симулятор (`flutter run` или Cmd+R из Xcode).
- [ ] Приложение запускается и отображает интерфейс (приветствие или Shell).
- [ ] В Console Xcode (Cmd+Shift+C) при переходах по экранам видны логи с тегом `[FinControl]`.

## Желательно

- [ ] Ученик открыл **View Debugger** (Debug → View Debugging → Capture View Hierarchy) и показал 3D-иерархию UI.
- [ ] Ученик запустил **Instruments** (Product → Profile) и показал один из шаблонов (Time Profiler, Allocations).
- [ ] Ученик использовал функции симулятора: Toggle Slow Animations, Save Screen, Record Screen.

## Что показать на созвоне

Симулятор iOS с FinControl, Console Xcode с логами `[FinControl]` при навигации. View Debugger или Instruments (если продемонстрировано). Подробнее: [exam-and-submission.md](../exam-and-submission.md#3-что-показать-и-что-сказать-на-экзамене-по-блокам).

## Результат

- [ ] **Принято** / **На доработку** (указать, что исправить): _____________________
