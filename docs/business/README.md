# Бизнесовая документация FinControl

Продуктовые и бизнес-требования к **одному продукту** — приложению FinControl (мобильное приложение на Flutter; веб-сборка опциональна для практик). Одно и то же приложение используется для всех практик: Charles, Proxyman, Android Studio, Xcode, ADB, Sentry, AppMetrica, TestFlight, Android-дистрибуция, Firebase.

**Из коробки:** приложение собирается и запускается после клонирования и шагов из `docs/practices/00-getting-started.md`. Интеграции Sentry, AppMetrica и Firebase не требуют правок кода — только подстановка токенов в указанный файл: `lib/config/student_env.dart` для Sentry и AppMetrica; конфиги Firebase (google-services.json, GoogleService-Info.plist) по инструкции в `docs/practices/00-firebase-setup.md`.

| Документ | Описание |
|----------|----------|
| [PRD_fin_control.md](PRD_fin_control.md) | Product Requirements Document: цель продукта, роли, функциональные и нефункциональные требования, ограничения, критерии готовности. |
| [milestones.md](milestones.md) | Этапы (майлстоуны): спринты, цели, задачи, критерии готовности по спринтам. |
