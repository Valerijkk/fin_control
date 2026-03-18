# Практики FinControl — пошагово (оглавление)

Подробные пошаговые инструкции разнесены по файлам в папке [practices/](practices/). Здесь — **однозначный порядок** прохождения: с чего начать и в какой последовательности выполнять практики.

Если что-то не получилось — смотри [FAQ.md](FAQ.md). Критерии приёмки по каждой практике — в [acceptance-criteria/](acceptance-criteria/).

**Токены Sentry и AppMetrica** вставляются **только** в указанный файл → [**lib/config/student_env.dart**](../lib/config/student_env.dart). Подробнее: [STUDENT_ENV.md](STUDENT_ENV.md).

---

## Порядок практик (полный, по шагам)

Рекомендуемый порядок совпадает с [practices/README.md](practices/README.md): сначала «Перед началом», затем инфраструктура (03, 04, 05), снифф (01, 02), мониторинг (06, 07), дистрибуция (08, 09), настройка Firebase (00), затем модули 10–15. **Нумерация практик (01, 02, … 15)** — по именам файлов в practices/.

| Шаг | № пр. | Практика | Файл с пошаговой инструкцией |
|-----|-------|----------|------------------------------|
| **0** | — | **Перед началом** (клонирование, первый запуск, Android Studio) | [practices/00-getting-started.md](practices/00-getting-started.md) |
| 1 | 03 | Android Studio (эмулятор, Logcat) | [practices/03-android-studio.md](practices/03-android-studio.md) |
| 2 | 04 | Xcode (симулятор iOS, консоль) | [practices/04-xcode.md](practices/04-xcode.md) |
| 3 | 05 | ADB (команды, логи, скриншоты) | [practices/05-adb.md](practices/05-adb.md) |
| 4 | 01 | Charles (перехват трафика) | [practices/01-charles.md](practices/01-charles.md) |
| 5 | 02 | Proxyman | [practices/02-proxyman.md](practices/02-proxyman.md) |
| 6 | 06 | Sentry (события и краши) | [practices/06-sentry.md](practices/06-sentry.md) |
| 7 | 07 | AppMetrica | [practices/07-appmetrica.md](practices/07-appmetrica.md) |
| 8 | 08 | TestFlight | [practices/08-testflight.md](practices/08-testflight.md) |
| 9 | 09 | Android-дистрибуция | [practices/09-android-distribution.md](practices/09-android-distribution.md) |
| **10** | 00 | **Firebase setup** (обязательно перед 10–15) | [practices/00-firebase-setup.md](practices/00-firebase-setup.md) |
| 11 | 10 | Firebase Crashlytics | [practices/10-firebase-crashlytics.md](practices/10-firebase-crashlytics.md) |
| 12 | 11 | Firebase FCM | [practices/11-firebase-fcm.md](practices/11-firebase-fcm.md) |
| 13 | 12 | Firebase Analytics | [practices/12-firebase-analytics.md](practices/12-firebase-analytics.md) |
| 14 | 13 | Firebase Remote Config | [practices/13-firebase-remote-config.md](practices/13-firebase-remote-config.md) |
| 15 | 14 | Firebase Performance | [practices/14-firebase-performance.md](practices/14-firebase-performance.md) |
| 16 | 15 | Firebase In-App Messaging | [practices/15-firebase-in-app-messaging.md](practices/15-firebase-in-app-messaging.md) |

**Итого:** шаг 0 — перед началом → 1–9 — практики 03,04,05, 01,02, 06,07, 08,09 → шаг 10 — Firebase setup → 11–16 — практики 10–15. Критерии приёмки: [acceptance-criteria/](acceptance-criteria/), полный список: [practices/README.md](practices/README.md).

---

## 2. Что должен уметь ученик после каждой практики

| Практика | Ключевой навык |
|----------|----------------|
| 00 Getting Started | Клонировать, собрать и запустить Flutter-приложение на эмуляторе/устройстве |
| 01 Charles | Перехватывать и расшифровывать HTTPS-трафик, использовать Breakpoints и Map Local для модификации ответов |
| 02 Proxyman | Настроить снифф трафика, использовать Breakpoint, Map Local и Network Conditions |
| 03 Android Studio | Работать с эмулятором, Logcat, Layout Inspector, App Inspection (DB Inspector), Profiler |
| 04 Xcode | Запустить на симуляторе iOS, просмотреть логи в Console, использовать Instruments и View Debugger |
| 05 ADB | Выполнять команды ADB: install, logcat, screencap, screenrecord, monkey, управление разрешениями |
| 06 Sentry | Подключить SDK, отправить тестовое событие, читать стек-трейсы и breadcrumbs |
| 07 AppMetrica | Подключить SDK, проверить сессии и устройства в отчётах |
| 08 TestFlight | Собрать iOS-архив, загрузить в App Store Connect, раздать через TestFlight |
| 09 Android-дистрибуция | Подписать release-сборку keystore, загрузить в Google Play / Firebase App Distribution |
| 10 Crashlytics | Перехватывать Flutter-ошибки, отправлять нефатальные ошибки, читать crash reports |
| 11 FCM | Запрашивать разрешения, получать FCM-токен, обрабатывать push в foreground/background |
| 12 Analytics | Логировать кастомные события и экраны, использовать DebugView, строить воронки |
| 13 Remote Config | Создавать параметры, менять поведение приложения без обновления, понимать rollout |
| 14 Performance | Добавлять кастомные трейсы, отслеживать метрики, искать регрессии по скорости |
| 15 In-App Messaging | Создавать кампании, настраивать триггеры, проверять показ in-app сообщений |

---

## 3. Чек-лист перед сдачей

- [ ] Проект клонирован, `flutter pub get` и `flutter run` выполняются без ошибок.
- [ ] В Android Studio открыта **корневая** папка проекта (где `pubspec.yaml`), а не папка `android/`.
- [ ] По каждой сдаваемой практике: выполнены все шаги из соответствующего файла в [practices/](practices/) и из этого документа.
- [ ] Можешь за 2–5 минут показать результат: запрос в Charles, логи в Logcat, событие в Sentry, сессию в AppMetrica и т.д.
- [ ] Можешь одним-двумя предложениями объяснить, что делал в практике.
- [ ] По продвинутым функциям (Breakpoints, Map Local, monkey, Network Conditions и др.) — можешь продемонстрировать хотя бы один сценарий модификации данных или стресс-тестирования.

---

## 4. Ссылки

- **Практики:** [practices/](practices/), [practices/README.md](practices/README.md)
- **Критерии приёмки:** [acceptance-criteria/](acceptance-criteria/), [acceptance-criteria/README.md](acceptance-criteria/README.md)
- **Сдача и экзамен:** [exam-and-submission.md](exam-and-submission.md)
- **Токены (Sentry/AppMetrica):** [STUDENT_ENV.md](STUDENT_ENV.md)
- **Вопросы и ответы:** [FAQ.md](FAQ.md)
- **Техническая и тестовая документация:** [technical/](technical/), [testing/](testing/), [business/](business/)
