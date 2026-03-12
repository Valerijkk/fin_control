# Запуск цикла Ральфа для FinControl (Flutter)

Проект FinControl — **Flutter** (Dart), а не Python/Flask. Правило [.cursor/rules/ralph-loop.mdc](../.cursor/rules/ralph-loop.mdc) изначально рассчитано на бэкенд (pytest, ruff). Ниже — адаптация под Flutter.

## Что делать агенту при выполнении задач

### TEST (вместо pytest + ruff)

Выполнять из **корня репозитория**:

1. **Тесты**:  
   `flutter test`  
   (при необходимости с таймаутом: `flutter test --timeout=120s`)

2. **Статический анализ**:  
   `flutter analyze`

Порог прохождения: тесты зелёные, `flutter analyze` без error (info/warning допустимы по соглашению проекта).

### IMPLEMENT

- Писать код на **Dart/Flutter** по спецификации из `docs/architecture.md`, `docs/data-models.md`, `docs/api-spec.md`.
- Не менять содержимое задач в `docs/tasks.json` — только поле **status** (`pending` → `in_progress` → `done` | `blocked`).

### DESIGN

- Для новых экранов/фич: описать виджеты, маршруты, вызовы API/репозиториев (без кода или с минимальным псевдокодом).
- Для практик: структура документа (разделы, чек-листы).

### Коммиты

- После каждой логически завершённой задачи — коммит. Язык сообщений — **русский**, по правилам [commit-messages.mdc](../.cursor/rules/commit-messages.mdc) и [commit-after-single-file.mdc](../.cursor/rules/commit-after-single-file.mdc).

---

## Как запустить цикл Ральфа

1. Открой правило [.cursor/rules/ralph-loop.mdc](../.cursor/rules/ralph-loop.mdc) и прочитай алгоритм (выбор задачи, DESIGN → IMPLEMENT → TEST → QA REVIEW → VERIFY, прогресс в `docs/progress.txt`).

2. Скажи агенту (в чате Cursor):

   **«Запусти цикл Ральфа по docs/tasks.json. Проект на Flutter: в шаге TEST выполняй `flutter test` и `flutter analyze` вместо pytest и ruff. Реализацию делай на Dart/Flutter. Используй docs/architecture.md и docs/data-models.md. Меняй в tasks.json только status.»**

3. Агент будет брать задачи со статусом **pending** по приоритету, выполнять их, дописывать прогресс в **docs/progress.txt** и обновлять **status** в **docs/tasks.json**.

4. Оставшиеся задачи (если есть) — интеграции: Sentry SDK, AppMetrica SDK, Firebase (проект + Crashlytics, FCM, Analytics, Remote Config, Performance, In-App Messaging). Их можно выполнять по одной через тот же цикл или вручную по описанию в задачах и практиках в **docs/practices/**.

---

## Текущее состояние задач

В **docs/tasks.json** в статусе **done** отмечены: все практики (01–15), базовая функциональность (БД, обменник, портфель, iOS, README), интеграции Sentry и AppMetrica (TASK-011, TASK-013). Остаётся **pending** только **TASK-017** (Firebase: создание проекта и подключение приложения) — для него нужны конфиги из консоли Firebase (`google-services.json`, `GoogleService-Info.plist`). После их добавления по инструкции из практик 10–15 интеграцию Firebase можно завершить вручную или через цикл Ральфа.
