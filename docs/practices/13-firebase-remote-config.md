# Практика: Firebase Remote Config — фичефлаги и rollout

**Одно приложение** FinControl. **Сначала [00-firebase-setup.md](00-firebase-setup.md):** свой проект Firebase, конфиги в проект, `Firebase.initializeApp()`. Затем добавляешь параметры в консоли и в коде читаешь их через `fetchAndActivate()` — поведение приложения меняется без обновления сборки.

## Цель

Подключить Firebase Remote Config к приложению FinControl (твой проект Firebase), добавить параметр (фичефлаг или значение) в консоли, изменить его и проверить, что приложение после `fetchAndActivate()` получает новое значение и меняет поведение (например скрытие вкладки «Портфель» или отображение комиссии).

## Важно: один проект Firebase

**Сначала [00-firebase-setup.md](00-firebase-setup.md):** свой проект, свои конфиги, `Firebase.initializeApp()`. Ключи Sentry/AppMetrica (практики 06–07) — в [STUDENT_ENV.md](../STUDENT_ENV.md), не здесь.

## Ожидаемый результат

- Параметры созданы в Firebase Console → **Remote Config** и опубликованы.
- Приложение при старте (или по кнопке «Обновить конфиг») вызывает `fetchAndActivate()` и читает значения (например `show_portfolio`, `commission_percent`).
- Изменение значения в консоли и повторный fetch в приложении приводят к изменению поведения (скрытие/показ вкладки, подпись о комиссии и т.п.).

## Что понадобится

- Ваш Firebase-проект (по [00-firebase-setup.md](00-firebase-setup.md))
- Добавьте в `pubspec.yaml` при необходимости `firebase_remote_config` (совместимую с firebase_core)

## Шаг 1: Подключение

Добавьте при необходимости `firebase_remote_config` в `pubspec.yaml`, выполните `flutter pub get`. Инициализация (в коде после `Firebase.initializeApp()`):

```dart
import 'package:firebase_remote_config/firebase_remote_config.dart';

final remoteConfig = FirebaseRemoteConfig.instance;

Future<void> initRemoteConfig() async {
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    minimumFetchInterval: const Duration(hours: 1), // в debug можно уменьшить
  ));
  await remoteConfig.setDefaults({'show_portfolio': true, 'commission_percent': 0.0});
  await remoteConfig.fetchAndActivate();
}
```

Вызовите `initRemoteConfig()` при старте приложения (например в `main()` или в корневом виджете).

## Шаг 2: Параметры в консоли

1. Firebase Console → **Remote Config**.
2. **Add parameter**: например `show_portfolio` (Boolean) — показывать ли вкладку «Портфель»; или `commission_percent` (Number) — «комиссия» для учебного сценария.
3. Установите значения по умолчанию и при необходимости **Conditions** (например по аудитории или процентам пользователей для rollout).
4. **Publish changes**.

## Шаг 3: Чтение в приложении

```dart
bool get showPortfolio => remoteConfig.getBool('show_portfolio');
double get commissionPercent => remoteConfig.getDouble('commission_percent');
```

Используйте в UI: например скрывайте вкладку «Портфель», если `showPortfolio == false`, или показывайте подпись «Комиссия: N%» при ненулевом `commissionPercent`.

## Шаг 4: Проверка rollout

1. В консоли измените значение параметра (например выключите `show_portfolio`) и опубликуйте.
2. В приложении вызовите снова `fetchAndActivate()` (перезапуск или кнопка «Обновить конфиг») и проверьте, что поведение изменилось.

## Проверка

- [ ] Выполнен [00-firebase-setup.md](00-firebase-setup.md).
- [ ] Параметры созданы в Firebase Console → **Remote Config** и опубликованы (Publish changes).
- [ ] Приложение получает значения после `fetchAndActivate()` (при старте или по кнопке).
- [ ] Изменение значения в консоли и повторный fetch в приложении приводят к изменению поведения в UI.

## Траблшутинг

- **Значения не обновляются** — убедись, что вызван `fetchAndActivate()` при старте или по кнопке; в консоли изменения опубликованы (Publish changes). [FAQ — Firebase](../FAQ.md#firebase).

## Практические сценарии Remote Config в FinControl

### Сценарий 1: Фичефлаг — скрытие вкладки

1. В Firebase Console → Remote Config → добавь параметр `show_portfolio` (Boolean, default: `true`).
2. Publish changes.
3. В коде приложения после `fetchAndActivate()` читай:
   ```dart
   final showPortfolio = remoteConfig.getBool('show_portfolio');
   ```
4. Используй в ShellScreen для скрытия/показа вкладки Портфель.
5. В консоли измени `show_portfolio` на `false` → Publish → в приложении сделай fetchAndActivate → вкладка исчезнет.

### Сценарий 2: A/B тест комиссии

1. Добавь параметр `commission_percent` (Number, default: `0`).
2. Добавь **Condition**: «50% пользователей» → значение `1.5`.
3. Publish.
4. В коде при обмене умножай результат на `(1 - commission/100)`:
   ```dart
   final commission = remoteConfig.getDouble('commission_percent');
   final finalAmount = toAmount * (1 - commission / 100);
   ```
5. **Результат:** 50% пользователей видят комиссию 1.5%, 50% — без комиссии.

### Сценарий 3: Динамический текст

1. Добавь параметр `welcome_message` (String, default: `Добро пожаловать в FinControl!`).
2. В WelcomeScreen подставь значение из Remote Config.
3. Меняй текст в консоли — приложение обновляет его при следующем запуске без обновления в магазине.

## Что показать на экзамене / созвоне

1. Покажи параметры в Firebase Console → Remote Config (например `show_portfolio`, `commission_percent`).
2. Запусти приложение — покажи, что параметры читаются (портфель виден/скрыт, комиссия отображается/нет).
3. Измени значение в консоли → Publish → в приложении вызови fetchAndActivate → покажи изменение поведения.
4. Кратко скажи: «Настроил Remote Config с двумя параметрами. Изменил значение в консоли — приложение обновило поведение после fetch без обновления сборки.»

## Дополнительно: сценарии для FinControl

### Рекомендуемые параметры

| Параметр | Тип | Описание | Как использовать |
|----------|-----|----------|------------------|
| `show_portfolio` | Boolean | Показывать вкладку Портфель | Скрывать/показывать tab в навигации |
| `show_stocks` | Boolean | Показывать вкладку Акции | Скрывать/показывать tab |
| `commission_percent` | Number | Комиссия при обмене (%) | Показывать подпись «Комиссия: N%» на экране обмена |
| `maintenance_mode` | Boolean | Режим обслуживания | Показывать баннер «Приложение на обслуживании» |
| `welcome_message` | String | Текст на приветственном экране | Менять текст без обновления |
| `max_expense_amount` | Number | Максимальная сумма расхода | Валидация формы |

### Conditions — целевые аудитории

В Firebase Console → Remote Config → **Conditions**:
- По стране (Geo targeting)
- По версии приложения
- По платформе (Android/iOS)
- По проценту пользователей (rollout: 10% → 50% → 100%)

**Сценарий:** показывай `commission_percent = 1.5` для 50% пользователей, `0` для остальных — A/B тест.

### minimumFetchInterval

В debug для быстрого тестирования уменьши интервал:
```dart
await remoteConfig.setConfigSettings(RemoteConfigSettings(
  fetchTimeout: const Duration(seconds: 10),
  minimumFetchInterval: Duration.zero, // мгновенное обновление в debug
));
```
**В production** оставь 1 час или больше — иначе Firebase заблокирует запросы (throttling).

## Ссылки

- [00-firebase-setup.md](00-firebase-setup.md) — обязательно перед этой практикой
- [Критерии приёмки 13 — Firebase Remote Config](../acceptance-criteria/13-firebase-remote-config.md)
- [FAQ — Firebase](../FAQ.md#firebase)
- [Список практик](README.md)
