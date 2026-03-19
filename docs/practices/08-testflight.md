# 🍎 Практика 08: TestFlight — сборка и публикация iOS-приложения

> Собираем iOS-сборку FinControl в Xcode, загружаем в App Store Connect и раздаём тестерам через TestFlight. Результат — тестер устанавливает приложение на реальное устройство по приглашению и может его тестировать.

---

## 🎯 Цель

Собрать приложение FinControl для iOS, подписать его в Xcode, загрузить архив в App Store Connect и раздать тестовую сборку через **TestFlight** так, чтобы тестер мог установить приложение на устройство по приглашению.

---

## ✅ Ожидаемый результат

- ✔️ В App Store Connect создано приложение с **Bundle ID**, совпадающим с FinControl
- ✔️ В Xcode настроено подписание (**Signing & Capabilities**)
- ✔️ Собран архив (**Product → Archive**) и загружен в App Store Connect
- ✔️ После обработки (10–30 минут) сборка появляется в **TestFlight → iOS Builds**
- ✔️ Добавлена группа тестеров (Internal или External Testing); тестеры по email получили приглашение
- ✔️ Тестер может установить приложение через приложение TestFlight на устройстве

> ⚠️ **Требуется Mac с Xcode** — без него невозможно собрать и подписать iOS-приложение. Подробнее: [FAQ — Нужен ли Mac](../FAQ.md#нужен-ли-mac-для-практик-по-ios-и-testflight).

---

## 📋 Что понадобится

| Что | Зачем |
|-----|-------|
| **Mac с Xcode** (последняя стабильная версия) | Сборка и подписание iOS-архива |
| **Аккаунт Apple Developer** (платный, $99/год) | Доступ к App Store Connect и TestFlight |
| Проект FinControl с папкой `ios/` | Исходный код для сборки |
| Реальное iOS-устройство у тестера | Установка через TestFlight (симулятор не подходит) |

---

## 📝 Пошаговая инструкция

### Шаг 1: Подготовка в App Store Connect

1. Открой [appstoreconnect.apple.com](https://appstoreconnect.apple.com) и войди с Apple ID, привязанным к Apple Developer Program.
2. Перейди в **My Apps** → нажми **+** → **New App**.
3. Заполни форму:
   - **Platform:** iOS
   - **Name:** FinControl
   - **Primary Language:** русский (или английский)
   - **Bundle ID:** выбери из списка (должен совпадать с `ios/Runner` — например `com.yourname.fincontrol`)
   - **SKU:** уникальный идентификатор (например `fincontrol-001`)
4. Нажми **Create**.
5. Запомни **Bundle ID** — он должен точно совпадать с тем, что указан в Xcode.

> 💡 Если нужного Bundle ID нет в списке, сначала создай **App ID** в [Apple Developer → Identifiers](https://developer.apple.com/account/resources/identifiers).

---

### Шаг 2: Настройка подписания в Xcode

1. Открой файл `ios/Runner.xcworkspace` в Xcode (именно `.xcworkspace`, не `.xcodeproj`).
2. В навигаторе проекта выбери таргет **Runner**.
3. Перейди на вкладку **Signing & Capabilities**.
4. Включи галочку **Automatically manage signing**.
5. В поле **Team** выбери свою команду Apple Developer.
6. Убедись, что **Bundle Identifier** совпадает с тем, что ты создал в App Store Connect.
7. В выпадающем списке устройств (toolbar сверху) выбери **Any iOS Device (arm64)** — это нужно для создания архива.

> ⚠️ Если видишь ошибку подписания — убедись, что ты залогинен в Xcode: **Xcode → Settings → Accounts** → добавь свой Apple ID.

---

### Шаг 3: Сборка архива

**Вариант A — через Xcode (рекомендуется):**

1. В Xcode выбери **Product → Archive**.
2. Дождись окончания сборки (может занять 3–10 минут).
3. После завершения автоматически откроется окно **Organizer** с твоим архивом.

**Вариант B — через терминал:**

```bash
# Из корня проекта FinControl
flutter build ipa
```

Готовый IPA можно загрузить через **Transporter** (скачай из App Store на Mac) или через Xcode Organizer.

---

### Шаг 4: Загрузка в App Store Connect

1. В окне **Organizer** (Xcode → Window → Organizer, если закрыл) выбери свой архив.
2. Нажми **Distribute App**.
3. Выбери **App Store Connect** → **Upload**.
4. Выбери опции распространения (оставь по умолчанию, если не уверен).
5. Нажми **Upload** и дождись завершения загрузки.
6. После успешной загрузки увидишь сообщение «Upload Successful».

> 📌 После загрузки Apple обрабатывает сборку — это занимает **10–30 минут**. Статус можно отслеживать в App Store Connect → TestFlight.

---

### Шаг 5: Настройка TestFlight и приглашение тестеров

1. Открой [App Store Connect](https://appstoreconnect.apple.com) → твоё приложение → вкладка **TestFlight**.
2. Дождись, пока сборка появится в разделе **iOS Builds** (после обработки).
3. Если Apple запрашивает — заполни:
   - **Export Compliance:** для FinControl выбери «Yes, uses encryption» → «Yes, exempt under standard exemption» (стандартный HTTPS)
   - **Content Rights** и **Advertising Identifier** — по необходимости
4. Добавь группу тестеров:
   - **Internal Testing** — для членов твоей команды Apple Developer (до 100 человек)
   - **External Testing** — для внешних тестеров по email (до 10 000 человек, требуется Beta App Review 1–2 дня)
5. Добавь email-адреса тестеров в группу.
6. Тестеры получат приглашение на email и смогут установить приложение через приложение **TestFlight** на своём устройстве.

> 💡 Для учебного проекта достаточно **Internal Testing** — оно не требует Beta App Review.

---

## 🔍 Проверка

- [ ] Bundle ID в Xcode (**Runner → General → Bundle Identifier**) совпадает с заведённым в App Store Connect
- [ ] Архив успешно создан (**Product → Archive**) и загружен через **Distribute App → App Store Connect → Upload**
- [ ] В App Store Connect → приложение → **TestFlight** сборка обработана и отображается в iOS Builds
- [ ] Добавлена группа тестеров (Internal или External); тестер получил приглашение по email
- [ ] Тестер может установить приложение через приложение TestFlight на реальном устройстве

---

## 🎓 Что показать на экзамене

1. Показать App Store Connect → твоё приложение → **TestFlight → iOS Builds**: сборка обработана
2. Показать группу тестеров (Internal или External) с добавленными email
3. На устройстве показать приложение **TestFlight** со списком доступных сборок FinControl
4. Запустить приложение из TestFlight — показать, что оно работает
5. Кратко сказать: *«Собрал архив в Xcode, загрузил в App Store Connect, добавил тестеров — приложение доступно через TestFlight»*

---

## 🛠 Траблшутинг

**No signing certificate / ошибка подписания**
→ Убедись, что в Xcode включен **Automatically manage signing** и выбрана правильная **Team**.
→ Если сертификата нет — создай его в [Apple Developer → Certificates](https://developer.apple.com/account/resources/certificates) или Xcode создаст его автоматически при включении Automatically manage signing.

**Provisioning profile issues**
→ При автоматическом подписании Xcode создаёт профиль сам. При ручном — создай **App ID** и **Provisioning Profile** (Distribution) в Developer Portal.

**Сборка не появляется в TestFlight**
→ Обработка занимает 10–30 минут. Проверь email — Apple отправит уведомление, когда сборка будет готова. Если прошло больше часа — проверь статус в **Activity** в App Store Connect.

**Archive не доступен (серый в меню)**
→ Убедись, что в toolbar Xcode выбрано устройство **Any iOS Device (arm64)**, а не конкретный симулятор.

**flutter build ipa завершается с ошибкой**
→ Проверь, что `ios/Runner.xcworkspace` открывается без ошибок в Xcode. Выполни `cd ios && pod install && cd ..` для обновления зависимостей.

---

## 🔗 Ссылки

- [Критерии приёмки 08 — TestFlight](../acceptance-criteria/08-testflight.md)
- [FAQ — Нужен ли Mac для практик iOS](../FAQ.md#нужен-ли-mac-для-практик-по-ios-и-testflight)
- [Список практик](README.md)

---

## 📚 Дополнительно: полезные возможности TestFlight

### Feedback от тестеров

- Тестеры могут отправлять feedback (скриншот + текст) прямо из приложения TestFlight — ты получишь его в App Store Connect → **TestFlight → Feedback**.
- Это удобно для сбора баг-репортов от ручных тестировщиков без отдельной баг-трекинговой системы.

---

### Несколько сборок

- Каждая новая сборка (с увеличенным build number в `pubspec.yaml`) автоматически появляется в TestFlight после загрузки.
- Тестеры могут переключаться между сборками — удобно для A/B-тестирования и проверки регрессий.
- Предыдущие сборки остаются доступными для сравнения.

---

### Internal vs External Testing

| Параметр | Internal Testing | External Testing |
|----------|-----------------|-----------------|
| **Кто может тестировать** | Члены команды Apple Developer | Любой по email |
| **Максимум тестеров** | 100 | 10 000 |
| **Нужна ли проверка Apple** | Нет | Да (Beta App Review, 1–2 дня) |
| **Для учебного проекта** | Достаточно | Не обязательно |

---

### Срок действия сборок

- Сборки в TestFlight доступны **90 дней** с момента загрузки.
- После истечения срока нужно загрузить новую сборку.
- TestFlight уведомит тестеров о скором истечении.

---

### Export Compliance

При загрузке Apple спросит об использовании шифрования:
- Для FinControl: стандартный HTTPS → выбирай **«Yes, uses encryption»** и **«Yes, exempt under standard exemption»** (стандартное исключение для HTTPS).
- Чтобы не отвечать каждый раз, можно добавить ключ `ITSAppUsesNonExemptEncryption = NO` в `Info.plist`.
