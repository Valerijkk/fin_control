# 📂 Бизнесовая документация FinControl

> 📌 **Одно приложение FinControl** (Flutter) используется для всех мобильных и веб-практик: Android, iOS, при необходимости Web. Одно и то же приложение — для всех 10 практик.

---

## 🚀 Запуск из коробки

Приложение собирается и запускается после клонирования и шагов из `docs/practices/00-getting-started.md`.

Интеграции **не требуют правок кода** — только подстановка токенов:

| Интеграция | Где подставлять |
|------------|----------------|
| **Sentry** | `lib/config/student_env.dart` → `sentryDsn` |
| **AppMetrica** | `lib/config/student_env.dart` → `appMetricaApiKey` |
| **Firebase** | `google-services.json` + `GoogleService-Info.plist` по инструкции в `docs/practices/10-firebase.md` |

---

## 📄 Документы

| Документ | Описание |
|----------|----------|
| 📋 [PRD_fin_control.md](PRD_fin_control.md) | Product Requirements Document: цель продукта, роли, функциональные и нефункциональные требования, ограничения, критерии готовности |
| 🗓️ [milestones.md](milestones.md) | Этапы (майлстоуны): спринты, цели, задачи, критерии готовности по спринтам |
