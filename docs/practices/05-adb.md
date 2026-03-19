# 🔌 Практика 05: ADB — Android Debug Bridge на примере FinControl

> Осваиваем **ADB** (Android Debug Bridge) — главный инструмент командной строки для работы с Android-устройствами. Установка/удаление приложений, логи, скриншоты, видео, управление разрешениями, стресс-тестирование monkey и многое другое — всё на примере FinControl.

---

## 🎯 Цель

Освоить основные команды ADB на примере FinControl: установка и удаление по пакету, просмотр и фильтрация логов (logcat), очистка данных, скриншоты, запись видео, запуск/остановка приложения, управление разрешениями, стресс-тестирование monkey, беспроводная отладка и работа с базой данных.

---

## ✅ Ожидаемый результат

- ✔ Подключённое устройство или эмулятор отображается в `adb devices`
- ✔ APK FinControl устанавливается через `adb install` и удаляется через `adb uninstall`
- ✔ Логи приложения просматриваются через `adb logcat` с фильтрацией по PID/тегу
- ✔ Данные приложения сбрасываются через `adb shell pm clear`
- ✔ Сделан скриншот и записано видео с экрана через ADB
- ✔ Выполнен monkey-тест без крашей приложения
- ✔ Освоены команды управления разрешениями, сетью, файлами и информацией об устройстве

---

## 📋 Что понадобится

| Что | Зачем |
|-----|-------|
| **Android SDK** (папка `platform-tools` с `adb` в PATH) | Сам инструмент ADB |
| **Устройство или эмулятор** | Цель для команд ADB |
| **Собранный APK FinControl** | Приложение для установки |
| **Package name** из `android/app/build.gradle.kts` | Идентификатор приложения для команд |

> 📌 **Package name** — это `applicationId` из файла `android/app/build.gradle.kts` (например `com.yourname.fincontrol.fin_control`). Этот идентификатор используется во всех командах ниже. Подробнее: [FAQ — Где указан package name](../FAQ.md#где-в-проекте-указан-package-name-applicationid-приложения).

**Подключение устройства:**
- **Эмулятор** — запусти из Android Studio (см. [03-android-studio.md](03-android-studio.md))
- **Реальное устройство** — подключи по USB, включи **Настройки → Для разработчиков → Отладка по USB**, подтверди разрешение на экране устройства

---

## 📝 Пошаговая инструкция

### Шаг 1: Проверка подключения

```bash
# Проверь, что устройство видно
adb devices
```

Должно отобразиться устройство или эмулятор, например:

```
List of devices attached
emulator-5554   device
```

> ⚠️ Если статус `unauthorized` — на экране устройства нажми «Разрешить отладку по USB». Если список пуст — проверь подключение кабеля и включение отладки.

---

### Шаг 2: Установка приложения

```bash
# Собери APK (если ещё не собран)
flutter build apk --debug

# Установи APK на устройство/эмулятор
# Флаг -r — переустановка с сохранением данных
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

> 💡 Флаг `-t` разрешает установку тестовых APK. Можно указать полный путь к APK, если он находится в другом месте.

---

### Шаг 3: Удаление приложения

```bash
# Удаление по имени пакета
adb uninstall com.yourname.fincontrol.fin_control
```

---

### Шаг 4: Просмотр логов (logcat)

```bash
# Все логи в реальном времени (много текста!)
adb logcat

# Только логи процесса FinControl (подставь свой package)
adb logcat --pid=$(adb shell pidof -s com.yourname.fincontrol.fin_control)

# Фильтр по тегу (если в коде используется тег FinControl)
adb logcat -s FinControl

# Очистить буфер логов и начать заново
adb logcat -c
adb logcat

# Сохранить текущий буфер логов в файл
adb logcat -d > logcat.txt
```

> 💡 Для баг-репортов сохраняй логи в файл с таймстампом:
> ```bash
> adb logcat -d > logcat_$(date +%Y%m%d_%H%M%S).txt
> ```

---

### Шаг 5: Очистка данных приложения

```bash
# Сброс данных и кэша (как «Очистить данные» в настройках)
adb shell pm clear com.yourname.fincontrol.fin_control
```

После этого приложение при следующем запуске будет как после первой установки — БД, SharedPreferences и кэш очищены.

---

### Шаг 6: Скриншоты

```bash
# Быстрый скриншот прямо на ПК
adb exec-out screencap -p > screenshot.png
```

Альтернативный способ (через устройство):

```bash
# Сохранить на устройство, потом скачать
adb shell screencap -p /sdcard/screen.png
adb pull /sdcard/screen.png
```

---

### Шаг 7: Запуск и остановка приложения

```bash
# Запуск главной активности
adb shell am start -n com.yourname.fincontrol.fin_control/.MainActivity

# Принудительная остановка приложения
adb shell am force-stop com.yourname.fincontrol.fin_control
```

---

### Шаг 8: Передача файлов

```bash
# С ПК на устройство
adb push local_file.json /sdcard/Download/

# С устройства на ПК
adb pull /sdcard/Download/file.json ./
```

---

### Шаг 9: Информация об устройстве

```bash
# Версия Android
adb shell getprop ro.build.version.release

# Модель устройства
adb shell getprop ro.product.model

# Найти пакет FinControl в списке установленных
adb shell pm list packages | grep fincontrol
```

> 📌 На Windows используй `findstr` вместо `grep`:
> ```bash
> adb shell pm list packages | findstr fincontrol
> ```

---

### Шаг 10: Запись видео с экрана

```bash
# Начать запись (до 3 минут по умолчанию, остановка — Ctrl+C)
adb shell screenrecord /sdcard/demo.mp4

# Скачать видео на ПК
adb pull /sdcard/demo.mp4
```

Полезные параметры:

| Параметр | Что делает | Пример |
|----------|-----------|--------|
| `--time-limit` | Ограничение по времени (сек) | `--time-limit 30` |
| `--size` | Разрешение видео | `--size 720x1280` |
| `--bit-rate` | Битрейт (качество) | `--bit-rate 4000000` |

> 💡 Прикладывай видео к баг-репортам — это гораздо нагляднее скриншотов.

---

### Шаг 11: Monkey — стресс-тестирование UI

Monkey генерирует случайные события (тапы, свайпы, повороты экрана) для проверки устойчивости приложения.

```bash
# Базовый тест: 500 случайных событий
adb shell monkey -p com.yourname.fincontrol.fin_control -v 500
```

| Параметр | Что делает |
|----------|-----------|
| `-p` | Пакет приложения (события только в нём) |
| `-v` | Уровень подробности логов (можно `-v -v` для максимума) |
| `500` | Количество случайных событий |
| `--throttle 100` | Задержка 100 мс между событиями |

Серьёзный стресс-тест с сохранением лога:

```bash
adb shell monkey -p com.yourname.fincontrol.fin_control --throttle 100 -v -v 5000 2>&1 | tee monkey_log.txt
```

**Что искать в результатах:** краши (CRASH), ANR (Application Not Responding), исключения. Если monkey нашёл краш — в логе будет стек-трейс с указанием места падения.

---

### Шаг 12: Беспроводная отладка (Wi-Fi)

#### Android 11+ (без USB)

1. На устройстве: **Настройки → Для разработчиков → Беспроводная отладка** → включить.
2. Нажми **Сопряжение устройства с помощью кода сопряжения** — появится IP, порт и код.
3. На ПК:
   ```bash
   # Сопряжение (одноразово)
   adb pair <IP>:<port_сопряжения>
   # Введи код сопряжения

   # Подключение
   adb connect <IP>:<port_отладки>
   ```

#### Android 10 и ниже (нужно первое подключение по USB)

```bash
# Переключить на TCP/IP режим (по USB)
adb tcpip 5555

# Отключить USB, подключиться по Wi-Fi
adb connect <IP_устройства>:5555
```

---

### Шаг 13: Управление разрешениями приложения

```bash
# Выдать разрешение
adb shell pm grant com.yourname.fincontrol.fin_control android.permission.CAMERA

# Отозвать разрешение
adb shell pm revoke com.yourname.fincontrol.fin_control android.permission.CAMERA
```

> 💡 Полезно для тестирования: как приложение ведёт себя без разрешения на камеру? Отзови → открой функцию, требующую камеру → проверь, что нет краша.

---

### Шаг 14: Управление сетью и авиарежим

```bash
# Включить авиарежим
adb shell settings put global airplane_mode_on 1
adb shell am broadcast -a android.intent.action.AIRPLANE_MODE

# Выключить авиарежим
adb shell settings put global airplane_mode_on 0
adb shell am broadcast -a android.intent.action.AIRPLANE_MODE
```

> 💡 Полезно для тестирования offline-режима: включи авиарежим → открой экран Обменник → проверь, что показываются кэшированные курсы или сообщение об ошибке.

---

### Шаг 15: Отправка Intent (deep link, действие)

```bash
# Открыть URL в браузере устройства
adb shell am start -a android.intent.action.VIEW -d "https://example.com"

# Отправить текст (share intent)
adb shell am start -a android.intent.action.SEND -t text/plain --es android.intent.extra.TEXT "Тестовый текст"
```

---

### Шаг 16: Информация о батарее и производительности

```bash
# Статистика батареи
adb shell dumpsys battery

# Информация о памяти приложения
adb shell dumpsys meminfo com.yourname.fincontrol.fin_control

# Общая статистика процессора
adb shell dumpsys cpuinfo
```

---

### Шаг 17: Работа с базой данных приложения (debug-сборка)

В debug-сборке можно извлечь файл БД для анализа:

```bash
# Вытащить файл базы данных
adb exec-out run-as com.yourname.fincontrol.fin_control cat databases/fin_control.db > fin_control.db
```

Затем открой в [DB Browser for SQLite](https://sqlitebrowser.org/) и проверь данные: таблицы `expenses`, `exchange_operations`, `portfolio_holdings`, `portfolio_transactions`, `price_alerts`, `limit_orders`, `savings_goals`.

---

## 🔍 Проверка

- [ ] `adb devices` показывает устройство или эмулятор (например `emulator-5554 device`)
- [ ] APK FinControl установлен через `adb install -r`; приложение открывается на устройстве
- [ ] Команда `adb logcat --pid=$(adb shell pidof -s <package>)` выводит логи процесса FinControl
- [ ] После `adb shell pm clear <package>` приложение показывается как после первой установки
- [ ] Скриншот сохранён на ПК: `adb exec-out screencap -p > screenshot.png`
- [ ] Запись видео: `adb shell screenrecord /sdcard/demo.mp4` → `adb pull` — файл MP4 сохранён
- [ ] Monkey-тест: `adb shell monkey -p <package> -v 500` выполнен без крашей

---

## 🎓 Что показать на экзамене

1. Покажи `adb devices` — устройство/эмулятор в списке.
2. Установи APK через `adb install -r` — приложение открывается.
3. Покажи логи: `adb logcat --pid=$(adb shell pidof -s <package>)` — фильтр по процессу.
4. Очисти данные: `adb shell pm clear <package>` — приложение сбрасывается.
5. Сделай скриншот: `adb exec-out screencap -p > screenshot.png` — файл сохранён.
6. Запиши видео экрана (5 секунд) и скачай на ПК.
7. Запусти monkey-тест на 200 событий — покажи, что приложение не упало.
8. Кратко скажи: «Освоил основные команды ADB: установка, удаление, логирование, скриншоты, видео, monkey-тестирование, управление разрешениями.»

---

## 🛠 Траблшутинг

**`adb devices` пустой или `unauthorized`**
→ Включи отладку по USB на устройстве (**Настройки → Для разработчиков → Отладка по USB**); на экране устройства подтверди разрешение. Для эмулятора — убедись, что он запущен.

**`pidof` не находит процесс**
→ Запусти приложение на устройстве и повтори команду. Проверь правильность package name (как в `build.gradle.kts`).

**`adb install` возвращает `INSTALL_FAILED_ALREADY_EXISTS`**
→ Используй флаг `-r` для переустановки: `adb install -r app.apk`.

**`adb install` возвращает `INSTALL_FAILED_TEST_ONLY`**
→ Добавь флаг `-t`: `adb install -r -t app.apk`.

**`run-as` не работает (Permission denied)**
→ Эта команда работает только с debug-сборками. Для release-сборок используй `adb pull` с root-доступом или App Inspection в Android Studio.

**`adb` не найден (command not found)**
→ Добавь путь к `platform-tools` в переменную PATH. Обычно это `~/Library/Android/sdk/platform-tools` (macOS) или `%LOCALAPPDATA%\Android\Sdk\platform-tools` (Windows).

---

## 🔗 Ссылки

- [Критерии приёмки 05 — ADB](../acceptance-criteria/05-adb.md)
- [FAQ — Где указан package name](../FAQ.md#где-в-проекте-указан-package-name-applicationid-приложения)
- [Список практик](README.md)

---

## 🧪 Практические сценарии

### Сценарий 1: Полный цикл установки и проверки

1. Собери APK:
   ```bash
   flutter build apk --debug
   ```
2. Установи:
   ```bash
   adb install -r build/app/outputs/flutter-apk/app-debug.apk
   ```
3. Запусти:
   ```bash
   adb shell am start -n com.yourname.fincontrol.fin_control/.MainActivity
   ```
4. Проверь логи:
   ```bash
   adb logcat | grep "\[FinControl\]"
   ```
   Должны появиться строки:
   ```
   [FinControl] Запуск приложения...
   [FinControl] Данные загружены
   ```
5. В приложении перейди на **Обменник** — в логах появится:
   ```
   [FinControl] ExchangeScreen: курсы загружены
   ```

---

### Сценарий 2: Тестирование offline-режима

1. Включи авиарежим через ADB:
   ```bash
   adb shell settings put global airplane_mode_on 1
   adb shell am broadcast -a android.intent.action.AIRPLANE_MODE
   ```
2. В приложении открой **Обменник** — курсы должны загрузиться из кэша (или показать ошибку).
3. В логах проверь:
   ```bash
   adb logcat -s FinControl
   ```
   Ожидай: `[FinControl] ExchangeScreen: ошибка загрузки курсов` (или загрузка из кэша).
4. Выключи авиарежим:
   ```bash
   adb shell settings put global airplane_mode_on 0
   adb shell am broadcast -a android.intent.action.AIRPLANE_MODE
   ```
5. Обнови курсы — должны загрузиться с API.

---

### Сценарий 3: Тестирование разрешения камеры

1. Отзови разрешение камеры:
   ```bash
   adb shell pm revoke com.yourname.fincontrol.fin_control android.permission.CAMERA
   ```
2. В приложении: **Добавить запись** → нажми **Прикрепить фото**.
3. **Ожидание:** приложение должно показать запрос разрешения или сообщение об ошибке, **не упасть**.
4. Верни разрешение:
   ```bash
   adb shell pm grant com.yourname.fincontrol.fin_control android.permission.CAMERA
   ```

---

### Сценарий 4: Стресс-тестирование monkey

1. Запусти monkey на 1000 событий с логированием:
   ```bash
   adb shell monkey -p com.yourname.fincontrol.fin_control --throttle 50 -v -v 1000 2>&1 | tee monkey_results.txt
   ```
2. Дождись завершения (1–2 минуты).
3. Проверь результат:
   ```bash
   # Поиск крашей
   grep CRASH monkey_results.txt

   # Поиск зависаний
   grep ANR monkey_results.txt
   ```
4. Если пусто — крашей и зависаний нет.
5. **Если нашёл краш:** в файле будет стек-трейс — скопируй его для баг-репорта.

---

### Сценарий 5: Проверка очистки данных

1. Добавь несколько записей расходов в приложении.
2. Сделай скриншот списка:
   ```bash
   adb exec-out screencap -p > before_clear.png
   ```
3. Очисти данные:
   ```bash
   adb shell pm clear com.yourname.fincontrol.fin_control
   ```
4. Запусти приложение:
   ```bash
   adb shell am start -n com.yourname.fincontrol.fin_control/.MainActivity
   ```
5. Сделай скриншот:
   ```bash
   adb exec-out screencap -p > after_clear.png
   ```
6. **Сравни:** после очистки приложение показывает приветственный экран, данных нет.

---

### Сценарий 6: Запись видео для баг-репорта

1. Начни запись (15 секунд):
   ```bash
   adb shell screenrecord --time-limit 15 /sdcard/bug_demo.mp4
   ```
2. В течение 15 секунд воспроизведи баг в приложении.
3. Скачай видео:
   ```bash
   adb pull /sdcard/bug_demo.mp4
   ```
4. Прикрепи видео к баг-репорту — гораздо нагляднее скриншота.

---

### Сценарий 7: Извлечение и проверка базы данных

1. Добавь запись расхода: «Кофе, 350 руб., категория Еда».
2. Извлеки БД:
   ```bash
   adb exec-out run-as com.yourname.fincontrol.fin_control cat databases/fin_control.db > fin_control.db
   ```
3. Открой в [DB Browser for SQLite](https://sqlitebrowser.org/).
4. Выполни запрос:
   ```sql
   SELECT title, amount, category FROM expenses ORDER BY date DESC LIMIT 5;
   ```
5. Проверь: запись «Кофе» с суммой 350 и категорией «Еда» присутствует.
6. **Для продвинутого тестирования:** проверь другие таблицы — `exchange_operations`, `portfolio_holdings`, `savings_goals`.
