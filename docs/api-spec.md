# API-спецификация FinControl

## Внешние API (используемые приложением)

### Курсы валют

**Провайдер 1 — exchangerate.host**

- **Метод**: GET
- **URL**: `https://api.exchangerate.host/latest?base=RUB&symbols=USD,EUR`
- **Заголовки**: Accept: application/json, User-Agent: fin_control/1.0
- **Ответ**: JSON с полями rates (объект с USD, EUR), date (строка даты)

**Провайдер 2 — open.er-api.com (fallback)**

- **Метод**: GET
- **URL**: `https://open.er-api.com/v6/latest/RUB`
- **Заголовки**: Accept: application/json, User-Agent: fin_control/1.0
- **Ответ**: JSON с result, rates (USD, EUR), time_last_update_unix

Оба запроса выполняются по HTTPS; при настройке Charles/Proxyman как прокси на устройстве/эмуляторе трафик виден в перехватчике.

---

## Внутренние эндпоинты

Собственного backend в текущем проекте нет. Все данные — локально (SQLite, SharedPreferences). При необходимости добавить минимальный демо-сервер для практик сниффа — описать отдельно в docs/practices.
