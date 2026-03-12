# Практика 00: Firebase — первый шаг

## Технология

**Firebase** — платформа Google для мобильных и веб-приложений: аналитика, краши, push-уведомления, удалённый конфиг, производительность и др. Тестировщику нужно уметь подключать приложение к своему проекту Firebase и проверять данные в консоли.

## В проекте FinControl

- В репозитории **нет** готовых конфигов Firebase (чужой проект не зашит).
- Ученик создаёт **свой** проект в Firebase Console, добавляет приложение Android (и при необходимости iOS), скачивает `google-services.json` и `GoogleService-Info.plist` и кладёт их в проект.
- Инициализация: один раз в `main.dart` вызывается `Firebase.initializeApp()`. Дальше по практикам 10–15 подключаются отдельные модули (Crashlytics, FCM, Analytics и т.д.).

## Задание

1. Создать проект в [Firebase Console](https://console.firebase.google.com).
2. Добавить приложение Android (указать package name из FinControl), скачать `google-services.json` → положить в `android/app/`.
3. При необходимости добавить iOS, скачать `GoogleService-Info.plist` → положить в `ios/Runner/`.
4. Добавить в проект `firebase_core`, настроить платформы по документации Flutter Firebase, в `main.dart` вызвать `Firebase.initializeApp()` перед `runApp()`.

**Полная пошаговая инструкция:** [docs/practices/00-firebase-setup.md](../../practices/00-firebase-setup.md).
