# Практика: Firebase Remote Config — фичефлаги и rollout

## Цель

Подключить Remote Config в FinControl, добавить параметр (фичефлаг или значение), изменить его в консоли и проверить, что приложение после fetch/activate получает новое значение и меняет поведение.

## Важно: свой проект Firebase

**Сначала [00-firebase-setup.md](00-firebase-setup.md):** свой проект, свои конфиги, `Firebase.initializeApp()`.

## Что понадобится

- Ваш Firebase-проект (по 00-firebase-setup.md)
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

## Что проверить

- [ ] Параметры созданы в Remote Config и опубликованы.
- [ ] Приложение получает значения после fetchAndActivate.
- [ ] Изменение в консоли приводит к изменению поведения в приложении после обновления конфига.
