# Как запустить FinControl в Android Studio на эмуляторе (Pixel 9)

## Почему «сотни ошибок»?

**Важно:** в Android Studio нужно открывать **корневую папку проекта** (ту, где лежит `pubspec.yaml`), а **не** папку `android/`.

- ❌ **Если открыть папку `android`** — Android Studio считает проект обычным Android-приложением. Flutter-плагины не подхватываются, Dart не распознаётся, Gradle ругается на отсутствующие модули → сотни ошибок.
- ✅ **Нужно открыть папку `fin_control`** (корень репозитория) — тогда Android Studio с установленным плагином Flutter видит проект как Flutter-приложение, и всё собирается и запускается нормально.

---

## Пошагово: что сделать

### 1. Закрыть текущий проект в Android Studio

**File → Close Project** (или закрыть окно).

### 2. Открыть именно корень проекта

1. **File → Open** (или на экране приветствия **Open**).
2. Укажи папку **`fin_control`** — ту, внутри которой есть:
   - `pubspec.yaml`
   - папки `lib/`, `android/`, `ios/`, `test/`, `docs/`
3. Нажми **OK**. Дождись индексации и синхронизации (внизу прогресс «Indexing…» / «Gradle sync»).

Не выбирай папку `android` и не открывай файл `android/build.gradle.kts` как проект.

### 3. Убедиться, что стоят плагины Flutter и Dart

1. **File → Settings** (или **Android Studio → Settings** на Mac).
2. **Plugins**.
3. Должны быть включены:
   - **Flutter**
   - **Dart**
4. Если их нет — установи из Marketplace и перезапусти Android Studio.

### 4. Запустить эмулятор Google Pixel 9

1. В Android Studio: **Tools → Device Manager** (или иконка телефона с зелёным треугольником на панели).
2. В списке устройств найди **Pixel 9** (или создай AVD с образом Pixel 9).
3. Нажми **Run** (▶) напротив этого эмулятора — он должен запуститься и появиться как окно/вкладка.

Если Pixel 9 нет в списке:
- **Create Device** → выбери **Pixel 9** → выбери системный образ (API 34 или 35) → **Finish**.

### 5. Запустить приложение на эмуляторе

1. В верхней панели Android Studio в выпадающем списке устройств должен появиться **запущенный эмулятор** (например «Pixel 9 API 34»).
2. Нажми зелёную кнопку **Run** (▶) или **Shift+F10** — запустится **Flutter Run**, приложение соберётся и установится на эмулятор.

Первый запуск может занять 1–3 минуты (Gradle, сборка).

---

## Если всё равно есть ошибки

### «flutter.sdk not set in local.properties»

В корне проекта выполни в терминале (в Cursor или в Android Studio: **View → Tool Windows → Terminal**):

```bash
flutter pub get
```

После этого в папке `android/` создастся/обновится `local.properties` с путём к Flutter SDK.

### Gradle sync failed

1. В Android Studio открой папку **корня проекта** (см. выше).
2. В терминале в корне проекта выполни:
   ```bash
   cd android
   ./gradlew --stop
   cd ..
   flutter clean
   flutter pub get
   ```
   (На Windows вместо `./gradlew` используй `gradlew.bat`.)
3. Снова **File → Sync Project with Gradle Files**.

### Эмулятор не появляется в списке устройств

В терминале в корне проекта:

```bash
flutter devices
```

Если эмулятор запущен, он должен быть в списке. Тогда можно запустить так:

```bash
flutter run
```

и выбрать нужное устройство (например Pixel 9).

---

## Кратко

1. Открывай в Android Studio **папку `fin_control`** (где `pubspec.yaml`), а не `android/`.
2. Установи плагины **Flutter** и **Dart**.
3. Запусти эмулятор **Pixel 9** из Device Manager.
4. Нажми **Run** (▶) — приложение запустится на эмуляторе.
