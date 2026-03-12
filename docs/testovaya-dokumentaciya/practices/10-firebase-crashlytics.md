# Практика 10: Firebase Crashlytics

## Технология

**Firebase Crashlytics** — отчётность о падениях и нефатальных ошибках в приложении. Интегрируется с Firebase-проектом, отчёты видны в консоли Firebase. Тестировщику нужно уметь подключать SDK и проверять появление крашей в отчётах.

## В проекте FinControl

- Crashlytics подключается после выполнения [00-firebase-setup](00-firebase-setup.md): свой проект Firebase, свои конфиги.
- В коде: перехват Flutter-ошибок и запись в Crashlytics; при необходимости кнопка тестового краша в настройках.

## Задание

1. Выполнить 00-firebase-setup (свой проект, конфиги, `Firebase.initializeApp()`).
2. Добавить `firebase_crashlytics`, настроить перехват ошибок в `main.dart`.
3. Вызвать тестовый краш (кнопка или `FirebaseCrashlytics.instance.crash()`).
4. Перезапустить приложение (отправка отчёта), проверить появление краша в Firebase Console → Crashlytics.

**Полная инструкция:** [docs/practices/10-firebase-crashlytics.md](../../practices/10-firebase-crashlytics.md).
