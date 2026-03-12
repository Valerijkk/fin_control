# Практика 09: Android-дистрибуция

## Технология

Распространение Android-сборок: подписанный APK/AAB, загрузка в Google Play (Internal testing) или Firebase App Distribution. Тестировщику нужно уметь собирать release, подписывать и доставлять сборку тестерам.

## В проекте FinControl

- Сборка: `flutter build apk` или `flutter build appbundle`.
- Подписание: keystore, настройка в `build.gradle`.
- Загрузка в выбранный канал (Play Console или Firebase App Distribution).

## Задание

1. Создать keystore и настроить подписание в проекте.
2. Собрать release APK или AAB.
3. Загрузить в Google Play Internal testing или в Firebase App Distribution.
4. Установить сборку на устройство из выбранного канала.

**Полная инструкция:** [docs/practices/09-android-distribution.md](../../practices/09-android-distribution.md).
