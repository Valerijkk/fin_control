# FinControl — простой и быстрый учёт расходов 💸

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Material 3](https://img.shields.io/badge/Material-3-7E57C2?logo=materialdesign&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-local-blue?logo=sqlite&logoColor=white)
![Platforms](https://img.shields.io/badge/Android-✓-34A853?logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-black)

Учебный pet-project на **Flutter** для **молниеносного учёта расходов/доходов**: локальная БД, фото чеков, умные фильтры, статистика, тёмная тема и офлайн-курсы валют. 🚀

---

## ✨ Возможности

- ⚡️ **Быстрая запись** (bottom-sheet: сумма + категория)
- 📝 Полная запись: **сумма, название, категория, доход/расход, дата**, **фото чека** (камера)
- 🏷️ **Свои категории** — добавляй прямо из формы/фильтра, всё сохраняется локально
- 🧹 Список с **свайп-удалением** и **UNDO** через Snackbar
- 🔎 **Поиск** по названию, фильтры по **категориям** и **периоду** (сегодня / 7 / 30 дней / всё)
- 📊 **Статистика**: суммы по категориям, доли расходов, общий итог
- 🌗 **Тёмная тема** (M3), быстрый переключатель в шапке и в настройках
- 💱 **Курсы валют (RUB→USD/EUR)**: 2 провайдера + кэш, офлайн-показ без падений
- 💾 Данные **офлайн** (SQLite через `sqflite`) + кэш курсов через `shared_preferences`

---

## 🧭 Структура проекта

````bash
lib/
├─ main.dart
├─ core/
│  ├─ routes.dart             # имена маршрутов
│  ├─ app\_theme.dart          # светлая/тёмная тема (Material 3)
│  ├─ categories.dart         # иконки/цвета/дефолтные категории
│  └─ formatters.dart         # money(), shortDayHeader(), isWithinDays()
├─ data/
│  ├─ db.dart                 # SQLite (sqflite)
│  └─ category\_store.dart     # персист пользовательских категорий (shared\_preferences)
├─ domain/
│  ├─ models/expense.dart
│  └─ repositories/expense\_repository.dart
├─ services/
│  └─ rates\_api.dart          # 2 провайдера курсов + кэш
├─ state/
│  ├─ app\_state.dart          # ChangeNotifier: CRUD/undo + категории
│  ├─ app\_scope.dart          # InheritedNotifier для доступа к состоянию
│  └─ theme\_controller.dart   # InheritedWidget для темы
└─ ui/
├─ screens/                # welcome, shell, home, add\_edit, stats, settings, photo\_viewer
└─ widgets/                # app\_bar\_title, theme\_action, settings\_action,
\# primary\_button, summary\_card, expense\_tile,
\# bar\_row, rates\_card
````

> Почему так? 🧩  
> – **UI** не знает про БД → вся работа с данными в `state`/`domain`.  
> – **AppState** говорит с репозиторием, а не с sqflite напрямую.  
> – **Services** (HTTP) отдельно от данных.  
> – Переиспользуемые компоненты — в `ui/widgets`.  
> – Форматирование денег/дат — централизовано.


## 🚀 Быстрый старт

````bash
git clone https://github.com/Valerijkk/fin_control.git
cd fin_control

flutter pub get
flutter run
````

**Требования**: Flutter **3.x** ✅  •  Dart **3.x** ✅


## 🔌 Платформенные настройки

### Android (`android/app/src/main/AndroidManifest.xml`) 📱

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourname.fincontrol.fin_control">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <!-- для SDK <= 32 -->
    <uses-permission
        android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />

    <application
        android:label="FinControl"
        android:icon="@mipmap/ic_launcher"
        android:enableOnBackInvokedCallback="true">
        <!-- ваши activity/intent-filter здесь -->
    </application>
</manifest>
```


## 🧪 Тесты

Структура:

```
test/
├─ flutter_test_config.dart            # init sqflite_common_ffi для тестов
├─ app_boot_test.dart
├─ helpers/test_host.dart
├─ unit/formatters_test.dart
└─ ui/screens/...
```

`test/flutter_test_config.dart`:

```dart
import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await testMain();
}
```

Запуск:

```bash
flutter test
```


## 💱 Курсы валют: как сделано

* Провайдеры: `exchangerate.host` → fallback `open.er-api.com`
* Таймауты и строгий парсинг JSON
* Кэш последнего успешного ответа (`shared_preferences`), отображаем **офлайн** (есть отметка)


## 🧑‍💻 Сценарии разработчика

```bash
# форматирование
dart format .

# статический анализ
flutter analyze

# сборка релиза Android
flutter build apk --release

# установка apk
flutter install
# или
adb install -r build/app/outputs/flutter-apk/app-release.apk
```


## 🛠️ Траблшутинг

* **`Locale data has not been initialized`** → локаль инициализируется в `main()` через `initializeDateFormatting('ru_RU')` (уже добавлено).
* **`databaseFactory not initialized` в тестах** → проверь `test/flutter_test_config.dart` (см. выше).
* **`dependOnInheritedWidgetOfExactType... before initState`** → читать `AppScope.of(context)` только в `didChangeDependencies()` (исправлено).
* **Курсы «ошибка загрузки»** → покажется кэш с пометкой «офлайн», как только сеть даст ответ — обновится.


## 📦 Основные зависимости

* `sqflite`, `path`
* `http`
* `image_picker`
* `intl`
* `shared_preferences`
* (dev) `sqflite_common_ffi`, `flutter_test`, `flutter_lints`


## 🔮 Roadmap

* 🌍 Локализация ru/en через `intl`/ARB
* 💱 Выбор базовой валюты + исторические графики
* 🧾 Экспорт/импорт (CSV/JSON)
* 🍰 Диаграммы в статистике (`fl_chart`)
* 🧹 Очистка прикреплённых фото при удалении записи
* 🧪 Golden-тесты UI


## 🤝 Контрибьюшн

PR’ы welcome! Соблюдай **flutter\_lints**, **Conventional Commits** и прикладывай хотя бы один тест к новой фиче. 🧪


## 📄 Лицензия

MIT — делай что хочешь, но сохраняй копирайт. ♥️

## 🙌 Спасибо

За интерес к аккуратному Flutter-коду, минимализму и прозрачной архитектуре.
Если проект зашёл — ⭐ звезда в репо и идеи в Issues.
**Good vibes only!** ✨