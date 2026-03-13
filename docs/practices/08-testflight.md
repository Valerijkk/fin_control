# Практика: iOS — сборка и публикация в TestFlight

## Цель

Собрать iOS-приложение FinControl, подписать его, загрузить в App Store Connect и раздать тестовую сборку через TestFlight.

## Что понадобится

- Аккаунт Apple Developer (платный, $99/год)
- macOS с Xcode
- Проект FinControl с папкой `ios/`

## Шаг 1: Подготовка в App Store Connect

1. Зайдите на [appstoreconnect.apple.com](https://appstoreconnect.apple.com).
2. **My Apps** → **+** → **New App**. Укажите название (FinControl), язык, Bundle ID (должен совпадать с `ios/Runner` — например `com.yourname.fincontrol`).
3. Запомните **Bundle ID** — он должен быть указан в Xcode в настройках проекта Runner.

## Шаг 2: Настройка подписания в Xcode

1. Откройте `ios/Runner.xcworkspace` в Xcode.
2. Выберите таргет **Runner** → вкладка **Signing & Capabilities**.
3. Включите **Automatically manage signing**, выберите вашу **Team** (Apple Developer).
4. Убедитесь, что **Bundle Identifier** совпадает с заведённым в App Store Connect.
5. Выберите устройство для сборки — **Any iOS Device (arm64)** для архива.

## Шаг 3: Сборка архива

1. В Xcode: **Product → Archive**.
2. Дождитесь окончания сборки. Откроется окно **Organizer** с архивом.
3. Нажмите **Distribute App** → **App Store Connect** → **Upload** → выберите опции (включите при необходимости Bitcode по требованию Apple) → **Upload**.

Либо из терминала (из корня проекта):

```bash
flutter build ipa
```

Готовый IPA можно загрузить через **Transporter** (из App Store) или через Xcode Organizer после архива.

## Шаг 4: Обработка и TestFlight

1. В App Store Connect → ваше приложение → **TestFlight**.
2. После обработки сборки (10–30 минут) она появится в разделе **iOS Builds**.
3. Заполните при необходимости **Export Compliance**, **Content Rights**, **Advertising Identifier** (в форме после загрузки).
4. Добавьте **Internal Testing** или **External Testing** группу, добавьте тестеров по email. Тестеры получат приглашение и смогут установить приложение через приложение TestFlight на устройстве.

## Что проверить

- [ ] Bundle ID совпадает в Xcode и App Store Connect.
- [ ] Архив успешно создан и загружен.
- [ ] Сборка обработана и отображается в TestFlight.
- [ ] Тестер может установить приложение через TestFlight на реальном устройстве.

## Устранение неполадок

- **No signing certificate**: создайте сертификат в Apple Developer → Certificates или дайте Xcode создать его автоматически.
- **Provisioning profile**: при автоматическом подписании Xcode создаст профиль сам; при ручном — создайте App ID и профиль дистрибуции в Developer Portal.
