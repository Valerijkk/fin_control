# Модели данных FinControl (SQLite)

## Существующие

### expenses (таблица)

- id INTEGER PRIMARY KEY
- title TEXT
- amount REAL
- category TEXT
- is_income INTEGER (0/1)
- date TEXT (ISO8601)
- photo_path TEXT (nullable)

### Категории

- Встроенные: в `lib/core/categories.dart`
- Пользовательские: персист в SharedPreferences через `CategoryStore`

---

## Новые таблицы

### exchange_operations

История операций обмена для экрана «Обменник» и тестов.

| Поле          | Тип     | Описание                          |
|---------------|---------|-----------------------------------|
| id            | INTEGER | PRIMARY KEY AUTOINCREMENT         |
| created_at    | TEXT    | ISO8601                           |
| amount_from   | REAL    | Сумма «из»                        |
| currency_from | TEXT    | Код валюты (RUB, USD, EUR)        |
| amount_to     | REAL    | Сумма «в»                         |
| currency_to   | TEXT    | Код валюты                        |
| rate_used     | REAL    | Курс на момент операции           |

### portfolio_balance

Одна запись: базовая валюта и текущий виртуальный баланс.

| Поле           | Тип    | Описание                |
|----------------|--------|-------------------------|
| base_currency  | TEXT   | RUB / USD / EUR         |
| balance        | REAL   | Текущий баланс          |
| updated_at     | TEXT   | ISO8601                 |

Вариант: хранить в SharedPreferences ключи `portfolio_base_currency`, `portfolio_balance`, `portfolio_updated_at`.

### portfolio_holdings

Виртуальные позиции по валютам.

| Поле       | Тип   | Описание                    |
|------------|-------|-----------------------------|
| id         | INTEGER | PRIMARY KEY              |
| currency   | TEXT  | USD, EUR и т.д.             |
| amount     | REAL  | Количество                  |
| avg_rate   | REAL  | Средняя цена входа в базе   |
| updated_at | TEXT  | ISO8601                     |

### portfolio_transactions

История сделок купли/продажи.

| Поле        | Тип    | Описание                          |
|-------------|--------|-----------------------------------|
| id          | INTEGER | PRIMARY KEY                     |
| created_at  | TEXT   | ISO8601                           |
| type        | TEXT   | 'buy' | 'sell'                      |
| currency    | TEXT   | Валюта актива                    |
| amount      | REAL   | Количество                        |
| rate        | REAL   | Курс на момент сделки             |
| total_base  | REAL   | Сумма в базовой валюте            |

---

## Индексы

- exchange_operations: индекс по created_at (для сортировки истории)
- portfolio_transactions: индекс по created_at
- portfolio_holdings: UNIQUE по currency (одна позиция на валюту)
