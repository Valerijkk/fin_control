# Практика: iOS — сборка и публикация в TestFlight

**Одно приложение** FinControl. Задача: собрать iOS-сборку, подписать в Xcode, загрузить в App Store Connect и раздать через TestFlight (тестеры устанавливают по приглашению). Требуется Mac и Xcode — см. [FAQ — Нужен ли Mac](../FAQ.md#нужен-ли-mac-для-практик-по-ios-и-testflight).

## Цель

Собрать приложение FinControl для iOS, подписать его в Xcode, загрузить архив в App Store Connect и раздать тестовую сборку через TestFlight так, чтобы тестер мог установить приложение на устройство по приглашению.

## Ожидаемый результат

- В App Store Connect создано приложение с Bundle ID, совпадающим с FinControl; в Xcode настроено подписание (Signing & Capabilities).
- Собран архив (Product → Archive), загружен в App Store Connect (Distribute App → Upload).
- После обработки (10–30 минут) сборка появляется в **TestFlight → iOS Builds**; заполнены при необходимости Export Compliance и др.
- Добавлена группа Internal или External Testing, тестеры по email получили приглашение и могут установить приложение через приложение TestFlight на устройстве.

---

## Что понадобится

- Аккаунт Apple Developer (платный, $99/год)
- macOS с Xcode
- Проект FinControl с папкой `ios/`

## Шаг 1: Подготовка в App Store Connect

1. Зайди на [appstoreconnect.apple.com](https://appstoreconnect.apple.com).
2. **My Apps** → **+** → **New App**. Укажи название (FinControl), язык, Bundle ID (должен совпадать с `ios/Runner` — например `com.yourname.fincontrol`).
3. Запомни **Bundle ID** — он должен быть указан в Xcode в настройках проекта Runner.

## Шаг 2: Настройка подписания в Xcode

1. Открой `ios/Runner.xcworkspace` в Xcode.
2. Выбери таргет **Runner** → вкладка **Signing & Capabilities**.
3. Включи **Automatically manage signing**, выбери свою **Team** (Apple Developer).
4. Убедись, что **Bundle Identifier** совпадает с заведённым в App Store Connect.
5. Выбери устройство для сборки — **Any iOS Device (arm64)** для архива.

## Шаг 3: Сборка архива

1. В Xcode: **Product → Archive**.
2. Дождись окончания сборки. Откроется окно **Organizer** с архивом.
3. Нажми **Distribute App** → **App Store Connect** → **Upload** → выбери опции (включи при необходимости Bitcode по требованию Apple) → **Upload**.

Либо из терминала (из корня проекта):

```bash
flutter build ipa
```

Готовый IPA можно загрузить через **Transporter** (из App Store) или через Xcode Organizer после архива.

## Шаг 4: Обработка и TestFlight

1. В App Store Connect → твоё приложение → **TestFlight**.
2. После обработки сборки (10–30 минут) она появится в разделе **iOS Builds**.
3. Заполни при необходимости **Export Compliance**, **Content Rights**, **Advertising Identifier** (в форме после загрузки).
4. Добавь **Internal Testing** или **External Testing** группу, добавь тестеров по email. Тестеры получат приглашение и смогут установить приложение через приложение TestFlight на устройстве.

## Проверка

- [ ] Bundle ID в Xcode (Runner → General → Bundle Identifier) совпадает с заведённым в App Store Connect.
- [ ] Архив успешно создан (Product → Archive) и загружен через Distribute App → App Store Connect → Upload.
- [ ] В App Store Connect → приложение → **TestFlight** сборка обработана и отображается в iOS Builds.
- [ ] Добавлена группа тестеров (Internal или External); тестер может установить приложение через приложение TestFlight на реальном устройстве.

## Траблшутинг

- **No signing certificate** — создай сертификат в [Apple Developer → Certificates](https://developer.apple.com/account/resources/certificates) или включи в Xcode **Automatically manage signing** — Xcode создаст сертификат сам.
- **Provisioning profile** — при автоматическом подписании Xcode создаёт профиль сам; при ручном создай App ID и профиль дистрибуции в Developer Portal.

## Что показать на экзамене / созвоне

1. Покажи App Store Connect → твоё приложение → **TestFlight** → iOS Builds: сборка обработана.
2. Покажи группу тестеров (Internal или External) с добавленными email.
3. На устройстве покажи приложение TestFlight со списком доступных сборок FinControl.
4. Запусти приложение из TestFlight — покажи, что оно работает.
5. Кратко скажи: «Собрал архив в Xcode, загрузил в App Store Connect, добавил тестеров — приложение доступно через TestFlight.»

## Дополнительно: полезные возможности TestFlight

### Feedback от тестеров
- Тестеры могут отправлять feedback (скриншот + текст) прямо из приложения TestFlight → ты получишь его в App Store Connect.
- Полезно для сбора баг-репортов от ручных тестировщиков.

### Несколько сборок
- Каждая новая сборка (с увеличенным build number) появляется в TestFlight.
- Тестеры могут переключаться между сборками — удобно для A/B-тестирования и проверки регрессий.

### External Testing
- Internal — до 100 тестеров (членов команды Apple Developer).
- External — до 10 000 тестеров по email; требуется проверка Apple (Beta App Review, 1-2 дня).
- Для учебного проекта достаточно Internal.

### Срок действия
- Сборки в TestFlight доступны **90 дней** с момента загрузки. После этого нужно загрузить новую.

### Export Compliance
- При загрузке Apple спросит об использовании шифрования. Для FinControl: стандартный HTTPS — отвечай **Yes, uses encryption** и **Yes, exempt under standard exemption** (стандартное исключение).

## Ссылки

- [Критерии приёмки 08 — TestFlight](../acceptance-criteria/08-testflight.md)
- [FAQ — Нужен ли Mac для практик iOS](../FAQ.md#нужен-ли-mac-для-практик-по-ios-и-testflight)
- [Список практик](README.md)
