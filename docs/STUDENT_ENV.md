# 🔐 Переменные для сборки под ученика

> Проект настроен **из коробки**. Для метрик и Firebase достаточно вставить токены в указанные места — **после подстановки всё работает**.

---

## 📍 Единственное место для токенов Sentry и AppMetrica

**Токены Sentry (DSN) и AppMetrica (API Key)** вставляются **только** в один файл:

> 📄 **[lib/config/student_env.dart](../lib/config/student_env.dart)**

В начале файла подписано, что куда вставлять и для какой практики. Других мест для этих ключей нет — **не дублируй** их в других файлах.

> 💡 Можно заполнять поэтапно: после практики 06 — только DSN → перезапуск → после практики 07 — API Key AppMetrica → перезапуск.
> Приложение при любом наборе (ни одного ключа / один / оба) работает корректно.

---

## 🔥 Firebase: конфиги по инструкции

Для практики **10 Firebase** (Setup, Crashlytics, FCM, Analytics, Remote Config, Performance, In-App Messaging) используются **конфиги Firebase**, а не `student_env.dart`.

| Файл | Платформа | Куда положить |
|------|-----------|---------------|
| `google-services.json` | Android | По инструкции в [10-firebase.md](practices/10-firebase.md) |
| `GoogleService-Info.plist` | iOS | По инструкции в [10-firebase.md](practices/10-firebase.md) |

> 📌 После добавления конфигов и вызова `Firebase.initializeApp()` — всё работает без дополнительной подстановки токенов.

---

## 📋 Какие переменные заполнять по практикам

| Практика | Переменная в `student_env.dart` | Откуда взять значение |
|----------|---------------------------------|----------------------|
| **06 Sentry** | `sentryDsn` | [sentry.io](https://sentry.io) → проект → Settings → Client Keys (DSN). Формат: `https://xxxx@xxxx.ingest.sentry.io/xxxx` |
| **07 AppMetrica** | `appMetricaApiKey` | [appmetrica.io](https://appmetrica.io) → приложение → настройки → API Key |
| **10 Firebase** | *не в этом файле* | Свой проект Firebase; конфиги по инструкции — [10-firebase.md](practices/10-firebase.md) |

Вставь значение **в пустую строку** между кавычками:
```dart
const String sentryDsn = 'https://xxx@xxx.ingest.sentry.io/xxx';
```
После изменения сохрани файл и перезапусти приложение (`flutter run`).

---

## 🔒 Безопасность ключей

> ⚠️ **Не коммить реальные ключи в репозиторий!**

- Файл `lib/config/student_env.dart` — для локальной разработки и практик
- При push — оставляй в константах **пустые строки** `''` или не включай заполненные значения в коммит
- **Один источник:** все ключи (Sentry, AppMetrica) — только в `student_env.dart`, не дублируй в других файлах
- **Для продакшена:** в реальных проектах секреты выносят в переменные окружения или защищённые конфиги; в учебном проекте достаточно не коммитить заполненный файл

---

## 🚀 Режимы запуска

### Без переменных (или заполнены не все)

Приложение собирается и работает: локальная БД, список расходов, обменник, портфель.
Sentry и AppMetrica не инициализируются — кнопка «Тест Sentry» не появится, события не уходят.

> 💡 Удобно для начала и практик 01–05 (Charles, ADB и т.д.)

### С заполненными переменными

Полноценный запуск: телеметрия и аналитика работают. Поэтапное выполнение учтено — можно вставить только DSN (для 06), перезапустить, потом добавить API Key (для 07).

---

## 🔗 Ссылки

| Ресурс | Ссылка |
|--------|--------|
| 📖 Практики | [practices-step-by-step.md](practices-step-by-step.md), [practices/](practices/), [practices/README.md](practices/README.md) |
| 🔥 Firebase | [10-firebase.md](practices/10-firebase.md) |
| 🎓 Сдача и экзамен | [exam-and-submission.md](exam-and-submission.md) |
| 📋 Критерии приёмки | [acceptance-criteria/](acceptance-criteria/) |
| ❓ FAQ | [FAQ.md](FAQ.md) |
| 📚 Документация | [README.md](README.md), [technical/](technical/), [testing/](testing/), [business/](business/) |
