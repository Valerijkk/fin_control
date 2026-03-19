# 🗓️ Этапы (майлстоуны) FinControl

> 📌 Все этапы относятся к **одному продукту** — приложению FinControl (мобильное на Flutter; веб — опционально). Одно и то же приложение используется для всех 10 практик.

> 💡 **Критерии готовности по проекту:** приложение собирается и запускается из коробки (по инструкции `docs/practices/00-getting-started.md`); интеграции Sentry, AppMetrica и Firebase требуют только подстановки токенов — `lib/config/student_env.dart` для Sentry/AppMetrica, конфиги Firebase по `docs/practices/10-firebase.md`.

---

## 🟢 Спринт 1: Ядро приложения

| | |
|---|---|
| **Цель** | В одном приложении FinControl работают обменник и мини-портфель, БД расширена |
| **Задачи** | TASK-001 — TASK-004 |

**Критерии готовности:**

- ✅ Приложение собирается и запускается из коробки (без ключей — базовый функционал доступен)
- ✅ Экраны «Обменник» и «Портфель» доступны в приложении
- ✅ Операции обмена и сделки портфеля сохраняются в SQLite

---

## 🔵 Спринт 2: Инструменты тестировщиков

| | |
|---|---|
| **Цель** | На базе того же приложения FinControl — практики по Charles, Proxyman, Android Studio, Xcode, ADB; интеграция Sentry и AppMetrica |
| **Задачи** | TASK-005 — TASK-014 |

**Критерии готовности:**

- ✅ Приложение собирается и запускается из коробки; для Sentry и AppMetrica достаточно подставить DSN/API Key в `lib/config/student_env.dart` (без правок кода)
- ✅ Практики написаны: Charles, Proxyman, Android Studio, Xcode, ADB, Sentry, AppMetrica (файлы `01`–`07` в `docs/practices`)
- ✅ Sentry SDK и AppMetrica SDK интегрированы в приложение
- ✅ Трафик приложения перехватывается в Charles/Proxyman; логи доступны в Android Studio/Xcode/ADB

---

## 🟣 Спринт 3: Дистрибуция и Firebase

| | |
|---|---|
| **Цель** | Сборки одного и того же приложения в TestFlight и по Android-дистрибуции; Firebase-проект и практики по всем модулям Firebase |
| **Задачи** | TASK-015 — TASK-024 |

**Критерии готовности:**

- ✅ Приложение собирается и запускается из коробки; для Firebase достаточно подставить конфиги по `docs/practices/10-firebase.md` (`google-services.json`, `GoogleService-Info.plist`), без правок кода
- ✅ Документация по сборкам: TestFlight (iOS), Android-дистрибуция (Google Play Internal testing или Firebase App Distribution)
- ✅ Практика по Firebase готова: `10-firebase.md` (setup + Crashlytics, FCM, Analytics, Remote Config, Performance Monitoring, In-App Messaging)
- ✅ README обновлён: учебная цель, ссылки на практики, требования для запуска

---

## 📊 Сводная таблица

| Спринт | Практики | Файлы |
|--------|----------|-------|
| 1 — Ядро | — | — |
| 2 — Инструменты | Charles, Proxyman, Android Studio, Xcode, ADB, Sentry, AppMetrica | `01`–`07` |
| 3 — Дистрибуция и Firebase | TestFlight, Android-дистрибуция, Firebase | `08`, `09`, `10` |
