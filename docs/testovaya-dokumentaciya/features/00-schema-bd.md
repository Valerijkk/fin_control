# Общая схема БД FinControl

Единая схема SQLite для тестовой документации и тест-кейсов.

## ER (сущности)

```mermaid
erDiagram
  expenses ||--o{ category_store : "category ref"
  expenses {
    TEXT id PK
    TEXT title
    REAL amount
    TEXT category
    INTEGER date
    INTEGER is_income
    TEXT image_path
  }

  exchange_operations {
    INTEGER id PK
    INTEGER created_at
    REAL amount_from
    TEXT currency_from
    REAL amount_to
    TEXT currency_to
    REAL rate_used
  }

  portfolio_holdings {
    INTEGER id PK
    TEXT currency UK
    REAL amount
    REAL avg_rate
    INTEGER updated_at
  }

  portfolio_transactions {
    INTEGER id PK
    INTEGER created_at
    TEXT type
    TEXT currency
    REAL amount
    REAL rate
    REAL total_base
  }
```

## Таблицы

| Таблица | Назначение |
|---------|------------|
| **expenses** | Расходы и доходы: id, title, amount, category, date, is_income, image_path |
| **exchange_operations** | История операций обменника: created_at, amount_from/to, currency_from/to, rate_used |
| **portfolio_holdings** | Позиции по валютам: currency (UNIQUE), amount, avg_rate, updated_at |
| **portfolio_transactions** | История сделок портфеля: type (buy/sell), currency, amount, rate, total_base |

Дополнительно: категории (встроенные в коде + пользовательские в SharedPreferences), кэш курсов и настройки (тема, базовая валюта) — SharedPreferences.

## Версия БД

- Текущая версия в коде: `_dbVersion = 3` (db.dart).
- Миграции: v1 → expenses; v2 → image_path; v3 → exchange_operations, portfolio_holdings, portfolio_transactions.
