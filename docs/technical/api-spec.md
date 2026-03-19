# 🌐 API-спецификация FinControl

> 📌 Спецификация внешних и внутренних API для **одного приложения FinControl**. Актуальная реализация — в `lib/services/` (`rates_api.dart`, `stocks_api.dart`, `crypto_api.dart` и др.).

---

## 📡 Внешние API (используемые приложением)

### 💱 Курсы валют

#### Провайдер 1 — exchangerate.host (основной)

| Параметр | Значение |
|----------|----------|
| **Метод** | `GET` |
| **URL** | `https://api.exchangerate.host/latest?base=RUB&symbols=USD,EUR` |
| **Заголовки** | `Accept: application/json`, `User-Agent: fin_control/1.0` |

**Формат ответа:**

```json
{
  "rates": { "USD": 0.012, "EUR": 0.011 },
  "date": "2026-03-19"
}
```

---

#### Провайдер 2 — open.er-api.com (fallback)

| Параметр | Значение |
|----------|----------|
| **Метод** | `GET` |
| **URL** | `https://open.er-api.com/v6/latest/RUB` |
| **Заголовки** | `Accept: application/json`, `User-Agent: fin_control/1.0` |

**Формат ответа:**

```json
{
  "result": "success",
  "rates": { "USD": 0.012, "EUR": 0.011 },
  "time_last_update_unix": 1710806400
}
```

---

> 💡 Оба запроса выполняются по HTTPS; при настройке Charles/Proxyman как прокси на устройстве/эмуляторе трафик виден в перехватчике.

---

## 🏠 Внутренние эндпоинты

Собственного backend в текущем проекте **нет**. Все данные — локально (SQLite, `SharedPreferences`).

> ⚠️ При необходимости добавить минимальный демо-сервер для практик сниффа — описать отдельно в [docs/practices/](../practices/).
