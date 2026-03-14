# Тестовая документация FinControl

Спецификации фич, тест-кейсы, ссылки на пошаговые практики и критерии приёмки.

## Запуск из коробки

**Одно приложение** FinControl: запускается без дополнительной настройки (`flutter run`). Весь функционал (учёт расходов, обменник, портфель, статистика, настройки) доступен сразу.

Для проверки **метрик и телеметрии** достаточно подставить ключи в указанный файл:

- **Sentry и AppMetrica** — только в [`lib/config/student_env.dart`](../../lib/config/student_env.dart): переменные `sentryDsn` и `appMetricaApiKey`. Подробности — [docs/STUDENT_ENV.md](../STUDENT_ENV.md).
- **Firebase** (Crashlytics, FCM, Analytics, Remote Config, Performance, In-App Messaging) — конфиги проекта по инструкциям в [docs/practices/](../practices/) (см. [00-firebase-setup](../practices/00-firebase-setup.md)).

После подстановки ключей приложение отправляет события в соответствующие сервисы; без ключей работает в режиме без телеметрии.

## Структура

| Раздел | Описание |
|--------|----------|
| [Фичи (features)](features/) | Спецификация по каждой фиче: бизнес- и функциональные требования, роли, схема БД, диаграммы состояний |
| [Тест-кейсы и автотесты](test-cases.md) | Ручные тест-кейсы и таблица автотестов по файлам |
| [Практики (ссылки)](practices/README.md) | Ссылки на пошаговые практики в [docs/practices/](../practices/) |
| [Критерии приёмки](../acceptance-criteria/README.md) | Чек-листы для приёмки выполненных практик (Charles, Proxyman, Sentry, AppMetrica, Firebase и др.) |

## Покрытие экранов

Тест-кейсы и фичи покрывают все экраны приложения по [архитектуре](../technical/architecture.md) и [PRD](../business/PRD_fin_control.md):

- **Учёт расходов** — список, добавление/редактирование, фильтры, UNDO, фото чека, цель накопления на главной ([01-uchyot-raskhodov](features/01-uchyot-raskhodov.md))
- **Обменник** — курсы, расчёт, история операций, оповещения по курсу, отложенные обмены (limit) ([02-obmennik](features/02-obmennik.md))
- **Портфель** — баланс, покупка/продажа активов, PnL/ROI, аллокация активов, история сделок ([03-portfel](features/03-portfel.md))
- **Статистика** — итоги расходов/доходов, разбивка по категориям ([04-statistika](features/04-statistika.md))
- **Настройки** — тема, базовая валюта, кэш курсов, очистка данных ([05-nastroyki](features/05-nastroyki.md))
- **Приветствие и навигация** — первый запуск, Shell, переключение вкладок ([06-privetstvie-navigaciya](features/06-privetstvie-navigaciya.md))
- **Цель накопления** — карточка на главной, добавление цели, пополнение, синхронизация с портфелем ([07-cel-nakopleniya](features/07-cel-nakopleniya.md))

## Связь с проектом

- **Исходники:** `lib/` — экраны, домен, данные, сервисы.
- **Автотесты:** `test/` — unit- и widget-тесты.
- **Практики (полные тексты):** [docs/practices/](../practices/).
- **Баг-лист для экзаменатора:** [acceptance-criteria/bugs-dlya-ekzamenatora.md](../acceptance-criteria/bugs-dlya-ekzamenatora.md).
