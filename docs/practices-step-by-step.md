# 🗺 Практики FinControl — пошагово (оглавление)

> Подробные инструкции — в папке [practices/](practices/).
> Здесь — **однозначный порядок** прохождения: с чего начать и в какой последовательности.

---

## 🔑 Быстрые ссылки

| Ресурс | Ссылка |
|--------|--------|
| ❓ Что-то не получилось? | [FAQ.md](FAQ.md) |
| 📋 Критерии приёмки | [acceptance-criteria/](acceptance-criteria/) |
| 🔐 Токены Sentry и AppMetrica | [STUDENT_ENV.md](STUDENT_ENV.md) → [`lib/config/student_env.dart`](../lib/config/student_env.dart) |

---

## 📋 1. Порядок практик (полный, по шагам)

> Рекомендуемый порядок: сначала «Перед началом», затем инструменты (03, 04, 05), снифф (01, 02), мониторинг (06, 07), дистрибуция (08, 09), и в конце Firebase (10).

| Шаг | № пр. | Практика | Файл с инструкцией |
|:---:|:-----:|----------|-------------------|
| **0** | — | **Перед началом** (клонирование, первый запуск) | [00-getting-started.md](practices/00-getting-started.md) |
| 1 | 03 | Android Studio (эмулятор, Logcat) | [03-android-studio.md](practices/03-android-studio.md) |
| 2 | 04 | Xcode (симулятор iOS, консоль) | [04-xcode.md](practices/04-xcode.md) |
| 3 | 05 | ADB (команды, логи, скриншоты) | [05-adb.md](practices/05-adb.md) |
| 4 | 01 | Charles (перехват трафика) | [01-charles.md](practices/01-charles.md) |
| 5 | 02 | Proxyman | [02-proxyman.md](practices/02-proxyman.md) |
| 6 | 06 | Sentry (события и краши) | [06-sentry.md](practices/06-sentry.md) |
| 7 | 07 | AppMetrica | [07-appmetrica.md](practices/07-appmetrica.md) |
| 8 | 08 | TestFlight | [08-testflight.md](practices/08-testflight.md) |
| 9 | 09 | Android-дистрибуция | [09-android-distribution.md](practices/09-android-distribution.md) |
| **10** | 10 | **Firebase** (полный гайд: setup → Crashlytics → FCM → Analytics → Remote Config → Performance → In-App Messaging) | [10-firebase.md](practices/10-firebase.md) |

> 💡 **Итого:** шаг 0 → шаги 1–9 (практики 03, 04, 05, 01, 02, 06, 07, 08, 09) → шаг 10 (Firebase — всё в одном файле).

---

## 🎓 2. Что должен уметь ученик после каждой практики

| Практика | Ключевой навык |
|----------|----------------|
| 00 Getting Started | Клонировать, собрать и запустить Flutter-приложение на эмуляторе/устройстве |
| 01 Charles | Перехватывать и расшифровывать HTTPS-трафик, использовать Breakpoints и Map Local |
| 02 Proxyman | Настроить снифф трафика, использовать Breakpoint, Map Local и Network Conditions |
| 03 Android Studio | Работать с эмулятором, Logcat, Layout Inspector, App Inspection, Profiler |
| 04 Xcode | Запустить на симуляторе iOS, просмотреть логи, использовать Instruments и View Debugger |
| 05 ADB | Команды: install, logcat, screencap, screenrecord, monkey, управление разрешениями |
| 06 Sentry | Подключить SDK, отправить событие, читать стек-трейсы и breadcrumbs |
| 07 AppMetrica | Подключить SDK, проверить сессии и устройства в отчётах |
| 08 TestFlight | Собрать iOS-архив, загрузить в App Store Connect, раздать через TestFlight |
| 09 Android-дистрибуция | Подписать release-сборку, загрузить в Google Play / Firebase App Distribution |
| 10 Firebase | Setup + Crashlytics + FCM + Analytics + Remote Config + Performance + In-App Messaging |

---

## ✅ 3. Чек-лист перед сдачей

- [ ] Проект клонирован, `flutter pub get` и `flutter run` выполняются без ошибок
- [ ] В Android Studio открыта **корневая** папка проекта (где `pubspec.yaml`), а не `android/`
- [ ] По каждой сдаваемой практике: выполнены все шаги из файла в [practices/](practices/)
- [ ] Можешь за 2–5 минут показать результат: запрос в Charles, логи в Logcat, событие в Sentry и т.д.
- [ ] Можешь одним-двумя предложениями объяснить, что делал в практике
- [ ] По продвинутым функциям (Breakpoints, Map Local, monkey и др.) — можешь продемонстрировать хотя бы один сценарий

---

## 🔗 4. Ссылки

| Ресурс | Ссылка |
|--------|--------|
| 📖 Практики | [practices/](practices/), [practices/README.md](practices/README.md) |
| 📋 Критерии приёмки | [acceptance-criteria/](acceptance-criteria/), [acceptance-criteria/README.md](acceptance-criteria/README.md) |
| 🎓 Сдача и экзамен | [exam-and-submission.md](exam-and-submission.md) |
| 🔑 Токены (Sentry/AppMetrica) | [STUDENT_ENV.md](STUDENT_ENV.md) |
| ❓ Вопросы и ответы | [FAQ.md](FAQ.md) |
| 📚 Документация | [technical/](technical/), [testing/](testing/), [business/](business/) |
