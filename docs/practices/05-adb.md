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

## Проверка

- [ ] `adb devices` показывает устройство или эмулятор (например `emulator-5554 device`).
- [ ] APK FinControl установлен через `adb install -r build/app/outputs/flutter-apk/app-debug.apk` (путь из корня проекта); приложение открывается на устройстве.
- [ ] Команда `adb logcat --pid=$(adb shell pidof -s com.yourname.fincontrol.fin_control)` выводит логи процесса FinControl (подставьте свой package name).
- [ ] После `adb shell pm clear com.yourname.fincontrol.fin_control` при следующем запуске приложение показывается как после первой установки (приветственный экран, данные очищены).
- [ ] Скриншот сохранён на ПК: `adb exec-out screencap -p > screenshot.png`.

## Траблшутинг

- **`adb devices` пустой или unauthorized** — включи отладку по USB на устройстве (Настройки → Для разработчиков → Отладка по USB); на экране устройства подтверди разрешение. Для эмулятора — убедись, что он запущен.
- **`pidof` не находит процесс** — запусти приложение на устройстве и повтори команду; проверь правильность package name (как в `build.gradle.kts`).

## Ссылки

- [Критерии приёмки 05 — ADB](../acceptance-criteria/05-adb.md)
- [FAQ — Где указан package name](../FAQ.md#где-в-проекте-указан-package-name-applicationid-приложения)
- [Список практик](README.md)
