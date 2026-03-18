# Практика: ADB — мануал по возможностям на основе FinControl

**Одно приложение** FinControl. Этот документ — **мануал по возможностям ADB** на его примере: установка/удаление по пакету, logcat по процессу, очистка данных, скриншоты, запуск/остановка, передача файлов, сведения об устройстве. Все команды используют package name из `android/app/build.gradle.kts` (`applicationId`).

## Цель

Освоить основные команды ADB (Android Debug Bridge) на примере FinControl: установка и удаление по пакету, просмотр и фильтрация логов (logcat), очистка данных приложения, скриншоты, запуск/остановка, передача файлов и сведение об устройстве. Все примеры даны для пакета FinControl (значение `applicationId` из `android/app/build.gradle.kts`).

## Ожидаемый результат

- Подключённое устройство или эмулятор отображается в `adb devices`.
- APK FinControl устанавливается через `adb install -r`; приложение удаляется через `adb uninstall` по пакету.
- Логи приложения просматриваются через `adb logcat` (в т.ч. по PID пакета); данные приложения сбрасываются через `adb shell pm clear`.
- Выполнены скриншот на ПК, запуск/остановка приложения по пакету, при необходимости — передача файлов и просмотр свойств устройства.

---

## Что понадобится

- Установленный Android SDK (папка `platform-tools` с `adb` в PATH) или Android Studio (тогда `adb` обычно уже в PATH).
- Подключённое по USB устройство с **включённой отладкой по USB** (Настройки → Для разработчиков) или **запущенный эмулятор** (запустите из Android Studio, см. [03-android-studio.md](03-android-studio.md)).
- Пакет FinControl: смотри в **`android/app/build.gradle.kts`** строку `applicationId` (например `com.yourname.fincontrol.fin_control`). Этот идентификатор используется во всех командах ниже. Подробнее: [FAQ — Где указан package name](../FAQ.md#где-в-проекте-указан-package-name-applicationid-приложения).

## Проверка подключения

```bash
adb devices
```

Должно отобразиться устройство или эмулятор (например `emulator-5554`).

---

## 1. Установка приложения

Установка APK (переустановка с сохранением данных по умолчанию не выполняется; `-r` — переустановка с сохранением данных):

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Или укажите полный путь к APK. Флаг `-t` разрешает установку тестовых APK.

---

## 2. Удаление приложения

По имени пакета (из `AndroidManifest.xml` / `android/app/build.gradle.kts`, например `com.yourname.fincontrol.fin_control`):

```bash
adb uninstall com.yourname.fincontrol.fin_control
```

---

## 3. Логи (logcat)

Вывод всех логов в реальном времени:

```bash
adb logcat
```

Только логи процесса FinControl (подставьте свой package):

```bash
adb logcat --pid=$(adb shell pidof -s com.yourname.fincontrol.fin_control)
```

Фильтр по тегу (если в коде используется тег, например `FinControl`):

```bash
adb logcat -s FinControl
```

Очистить буфер logcat и затем смотреть логи:

```bash
adb logcat -c
adb logcat
```

Сохранение логов в файл:

```bash
adb logcat -d > logcat.txt
```

---

## 4. Очистка данных приложения

Сброс данных и кэша приложения (как «Очистить данные» в настройках):

```bash
adb shell pm clear com.yourname.fincontrol.fin_control
```

После этого приложение при следующем запуске будет как после первой установки (БД, SharedPreferences очищены).

---

## 5. Скриншоты

Скриншот с устройства/эмулятора в файл на ПК:

```bash
adb exec-out screencap -p > screenshot.png
```

Или сохранение на устройство с последующим pull:

```bash
adb shell screencap -p /sdcard/screen.png
adb pull /sdcard/screen.png
```

---

## 6. Запуск приложения по пакету и активности

Запуск главной активности (пример; актуальное имя смотрите в манифесте):

```bash
adb shell am start -n com.yourname.fincontrol.fin_control/.MainActivity
```

Остановка приложения:

```bash
adb shell am force-stop com.yourname.fincontrol.fin_control
```

---

## 7. Передача файлов

С ПК на устройство:

```bash
adb push local_file.json /sdcard/Download/
```

С устройства на ПК:

```bash
adb pull /sdcard/Download/file.json ./
```

---

## 8. Информация об устройстве

Версия Android, модель и т.д.:

```bash
adb shell getprop ro.build.version.release
adb shell getprop ro.product.model
```

Список установленных пакетов:

```bash
adb shell pm list packages | findstr fincontrol
```

(На macOS/Linux используйте `grep` вместо `findstr`.)

---

## 9. Запись видео с экрана

Запись экрана устройства (до 3 минут по умолчанию):

```bash
adb shell screenrecord /sdcard/demo.mp4
```

Остановка — Ctrl+C в терминале. Затем скачай файл:

```bash
adb pull /sdcard/demo.mp4
```

Параметры: `--time-limit 30` (секунды), `--size 720x1280` (разрешение), `--bit-rate 4000000` (битрейт).

Полезно для записи воспроизведения бага — прикладывай к баг-репорту.

---

## 10. Monkey — стресс-тестирование UI

Monkey генерирует случайные события (тапы, свайпы, повороты экрана) для проверки устойчивости приложения:

```bash
adb shell monkey -p com.yourname.fincontrol.fin_control -v 500
```

- `-p` — пакет приложения (события только в нём)
- `-v` — уровень подробности логов
- `500` — количество случайных событий

Больше событий для серьёзного стресс-теста:

```bash
adb shell monkey -p com.yourname.fincontrol.fin_control --throttle 100 -v -v 5000 2>&1 | tee monkey_log.txt
```

- `--throttle 100` — задержка 100 мс между событиями (имитация реального пользователя)
- `-v -v` — подробный вывод
- `2>&1 | tee` — сохранение лога

**Что искать:** краши (CRASH), ANR (Application Not Responding), исключения. Если monkey нашёл краш — в логе будет стек-трейс с указанием места падения.

---

## 11. Беспроводная отладка (Wi-Fi)

Подключение без USB-кабеля (Android 11+):

1. На устройстве: **Настройки → Для разработчиков → Беспроводная отладка** → включить.
2. Нажми **Сопряжение устройства с помощью кода сопряжения** — появится IP, порт и код.
3. На ПК:

```bash
adb pair <IP>:<port_сопряжения>
```

Введи код сопряжения. Затем подключись:

```bash
adb connect <IP>:<port_отладки>
```

Для Android 10 и ниже (нужно первое подключение по USB):

```bash
adb tcpip 5555
adb connect <IP_устройства>:5555
```

---

## 12. Управление разрешениями приложения

Выдать разрешение:

```bash
adb shell pm grant com.yourname.fincontrol.fin_control android.permission.CAMERA
```

Отозвать разрешение:

```bash
adb shell pm revoke com.yourname.fincontrol.fin_control android.permission.CAMERA
```

Полезно для тестирования: как приложение ведёт себя без разрешения на камеру? Отзови — открой экран добавления расхода с фото — проверь, что нет краша.

---

## 13. Управление сетью и авиарежим

Включение/выключение авиарежима:

```bash
adb shell settings put global airplane_mode_on 1
adb shell am broadcast -a android.intent.action.AIRPLANE_MODE

adb shell settings put global airplane_mode_on 0
adb shell am broadcast -a android.intent.action.AIRPLANE_MODE
```

Полезно для тестирования offline-режима: включи авиарежим → открой экран Обменник → проверь, что показываются кэшированные курсы или сообщение об ошибке.

---

## 14. Отправка Intent (deep link, действие)

Открыть URL в браузере устройства:

```bash
adb shell am start -a android.intent.action.VIEW -d "https://example.com"
```

Отправить текст в приложение (share intent):

```bash
adb shell am start -a android.intent.action.SEND -t text/plain --es android.intent.extra.TEXT "Тестовый текст"
```

---

## 15. Информация о батарее и производительности

Статистика батареи:

```bash
adb shell dumpsys battery
```

Информация о памяти приложения:

```bash
adb shell dumpsys meminfo com.yourname.fincontrol.fin_control
```

Общая статистика процессора:

```bash
adb shell dumpsys cpuinfo
```

---

## 16. Работа с базой данных приложения (debug-сборка)

В debug-сборке можно вытащить файл БД:

```bash
adb exec-out run-as com.yourname.fincontrol.fin_control cat databases/fin_control.db > fin_control.db
```

Затем открыть в [DB Browser for SQLite](https://sqlitebrowser.org/) и проверить данные: таблицы `expenses`, `exchange_operations`, `portfolio_holdings` и т.д.

Полезно для проверки: добавил расход в приложении → вытащил БД → проверил, что запись корректно сохранена в таблицу `expenses`.

---

## Проверка

- [ ] `adb devices` показывает устройство или эмулятор (например `emulator-5554 device`).
- [ ] APK FinControl установлен через `adb install -r build/app/outputs/flutter-apk/app-debug.apk` (путь из корня проекта); приложение открывается на устройстве.
- [ ] Команда `adb logcat --pid=$(adb shell pidof -s com.yourname.fincontrol.fin_control)` выводит логи процесса FinControl (подставьте свой package name).
- [ ] После `adb shell pm clear com.yourname.fincontrol.fin_control` при следующем запуске приложение показывается как после первой установки (приветственный экран, данные очищены).
- [ ] Скриншот сохранён на ПК: `adb exec-out screencap -p > screenshot.png`.
- [ ] Запись видео: `adb shell screenrecord /sdcard/demo.mp4` → `adb pull /sdcard/demo.mp4` — файл mp4 сохранён.
- [ ] Monkey-тест: `adb shell monkey -p <package> -v 500` выполнен без крашей приложения.

## Что показать на экзамене / созвоне

1. Покажи `adb devices` — устройство/эмулятор в списке.
2. Установи APK через `adb install -r` — приложение открывается.
3. Покажи логи: `adb logcat --pid=$(adb shell pidof -s <package>)` — фильтр по процессу.
4. Очисти данные: `adb shell pm clear <package>` — приложение сбрасывается.
5. Сделай скриншот: `adb exec-out screencap -p > screenshot.png` — файл сохранён.
6. Запиши видео экрана (5 секунд) и скачай на ПК.
7. Запусти monkey-тест на 200 событий — покажи, что приложение не упало.
8. Кратко скажи: «Освоил основные команды ADB: установка, удаление, логирование, скриншоты, видео, monkey-тестирование, управление разрешениями.»

## Траблшутинг

- **`adb devices` пустой или unauthorized** — включи отладку по USB на устройстве (Настройки → Для разработчиков → Отладка по USB); на экране устройства подтверди разрешение. Для эмулятора — убедись, что он запущен.
- **`pidof` не находит процесс** — запусти приложение на устройстве и повтори команду; проверь правильность package name (как в `build.gradle.kts`).

## Ссылки

- [Критерии приёмки 05 — ADB](../acceptance-criteria/05-adb.md)
- [FAQ — Где указан package name](../FAQ.md#где-в-проекте-указан-package-name-applicationid-приложения)
- [Список практик](README.md)
