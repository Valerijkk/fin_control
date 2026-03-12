# Практика: ADB — мануал по возможностям на основе FinControl

## Цель

Освоить основные команды ADB (Android Debug Bridge) на примере приложения FinControl: установка, логи, очистка данных, скриншоты и др.

## Требования

- Установленный Android SDK (папка `platform-tools` с `adb` в PATH) или Android Studio.
- Подключённое по USB устройство с включённой отладкой по USB или запущенный эмулятор.

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

По имени пакета (из `AndroidManifest.xml` / `build.gradle`, например `com.yourname.fincontrol.fin_control`):

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

## Чек-лист для ученика (на примере FinControl)

- [ ] `adb devices` — устройство/эмулятор виден.
- [ ] Установить APK через `adb install -r ...`.
- [ ] Запустить приложение, выполнить действия, посмотреть логи через `adb logcat`.
- [ ] Выполнить `pm clear` по пакету, снова открыть приложение — данные сброшены.
- [ ] Сделать скриншот через `screencap` и сохранить на ПК.
