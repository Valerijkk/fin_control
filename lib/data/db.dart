// Локальная БД SQLite: таблицы расходов, операций обмена, портфеля (позиции и сделки).
// Асинхронность: все методы возвращают Future; sqflite выполняет запросы в фоне — UI не блокируется.
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Единая точка доступа к БД. Версия 4: price_alerts, limit_orders, savings_goals (оповещения по курсу, отложенные обмены, цели накопления).
/// Все методы асинхронны; sqflite выполняет запросы в фоновом потоке, UI не блокируется.
class AppDatabase {
  static const _dbName = 'fincontrol.db';
  /// При увеличении версии срабатывает [onUpgrade] (миграции).
  static const _dbVersion = 4;

  Database? _db;

  /// Открывает БД (создаёт файл при первом запуске, при апгрейде вызывает [onUpgrade]).
  Future<Database> _open() async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE expenses(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            date INTEGER NOT NULL,
            is_income INTEGER NOT NULL,
            image_path TEXT
          )
        ''');
        await _createExchangeAndPortfolioTables(db);
        await _createAlertsLimitOrdersSavingsTables(db);
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await db.execute('ALTER TABLE expenses ADD COLUMN image_path TEXT');
        }
        if (oldV < 3) {
          await _createExchangeAndPortfolioTables(db);
        }
        if (oldV < 4) {
          await _createAlertsLimitOrdersSavingsTables(db);
        }
      },
    );
    return _db!;
  }

  /// Создаёт таблицы обменника и портфеля (используется в [onCreate] и при апгрейде с версии < 3).
  static Future<void> _createExchangeAndPortfolioTables(Database db) async {
    await db.execute('''
      CREATE TABLE exchange_operations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at INTEGER NOT NULL,
        amount_from REAL NOT NULL,
        currency_from TEXT NOT NULL,
        amount_to REAL NOT NULL,
        currency_to TEXT NOT NULL,
        rate_used REAL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE portfolio_holdings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        currency TEXT NOT NULL UNIQUE,
        amount REAL NOT NULL,
        avg_rate REAL NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE portfolio_transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at INTEGER NOT NULL,
        type TEXT NOT NULL,
        currency TEXT NOT NULL,
        amount REAL NOT NULL,
        rate REAL NOT NULL,
        total_base REAL NOT NULL
      )
    ''');
  }

  // --- Expenses: сырые CRUD для [ExpenseRepository] ---

  /// Все записи из таблицы [expenses], сортировка по дате (новые сверху).
  Future<List<Map<String, Object?>>> getAllRaw() async {
    final db = await _open();
    return db.query('expenses', orderBy: 'date DESC');
  }

  Future<void> insertRaw(Map<String, Object?> values) async {
    final db = await _open();
    await db.insert('expenses', values, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateRaw(String id, Map<String, Object?> values) async {
    final db = await _open();
    await db.update('expenses', values, where: 'id=?', whereArgs: [id]);
  }

  Future<void> deleteById(String id) async {
    final db = await _open();
    await db.delete('expenses', where: 'id=?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await _open();
    await db.delete('expenses');
  }

  // --- Exchange: история операций обменника ---

  /// Все операции обмена, сортировка по дате (новые сверху).
  Future<List<Map<String, Object?>>> getExchangeOperationsRaw() async {
    final db = await _open();
    return db.query('exchange_operations', orderBy: 'created_at DESC');
  }

  Future<void> insertExchangeOperationRaw(Map<String, Object?> values) async {
    final db = await _open();
    await db.insert('exchange_operations', values);
  }

  // --- Portfolio: позиции по валютам/тикерам ---

  /// Все позиции в портфеле (одна строка на валюту/тикер).
  Future<List<Map<String, Object?>>> getPortfolioHoldingsRaw() async {
    final db = await _open();
    return db.query('portfolio_holdings');
  }

  Future<void> insertPortfolioHoldingRaw(Map<String, Object?> values) async {
    final db = await _open();
    await db.insert('portfolio_holdings', values);
  }

  Future<void> updatePortfolioHoldingById(
      int id, Map<String, Object?> values) async {
    final db = await _open();
    await db.update('portfolio_holdings', values,
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updatePortfolioHoldingByCurrency(
      String currency, Map<String, Object?> values) async {
    final db = await _open();
    await db.update('portfolio_holdings', values,
        where: 'currency = ?', whereArgs: [currency]);
  }

  Future<Map<String, Object?>?> getPortfolioHoldingByCurrency(String currency) async {
    final db = await _open();
    final list = await db.query('portfolio_holdings',
        where: 'currency = ?', whereArgs: [currency]);
    return list.isNotEmpty ? list.first : null;
  }

  Future<void> deletePortfolioHoldingByCurrency(String currency) async {
    final db = await _open();
    await db.delete('portfolio_holdings', where: 'currency = ?', whereArgs: [currency]);
  }

  // --- Portfolio: история сделок купли/продажи ---

  /// Все сделки, сортировка по дате (новые сверху).
  Future<List<Map<String, Object?>>> getPortfolioTransactionsRaw() async {
    final db = await _open();
    return db.query('portfolio_transactions', orderBy: 'created_at DESC');
  }

  Future<void> insertPortfolioTransactionRaw(Map<String, Object?> values) async {
    final db = await _open();
    await db.insert('portfolio_transactions', values);
  }

  // --- Price alerts: оповещение при достижении курса ---

  static Future<void> _createAlertsLimitOrdersSavingsTables(Database db) async {
    await db.execute('''
      CREATE TABLE price_alerts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        currency_from TEXT NOT NULL,
        currency_to TEXT NOT NULL,
        target_rate REAL NOT NULL,
        is_above INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        notified INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE limit_orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        currency_from TEXT NOT NULL,
        currency_to TEXT NOT NULL,
        amount_from REAL NOT NULL,
        target_rate REAL NOT NULL,
        is_above INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');
    await db.execute('''
      CREATE TABLE savings_goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        target_amount REAL NOT NULL,
        base_currency TEXT NOT NULL,
        current_amount REAL NOT NULL DEFAULT 0,
        deadline INTEGER,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  Future<List<Map<String, Object?>>> getPriceAlertsRaw({bool onlyPending = true}) async {
    final db = await _open();
    if (onlyPending) {
      return db.query('price_alerts', where: 'notified = 0', orderBy: 'created_at DESC');
    }
    return db.query('price_alerts', orderBy: 'created_at DESC');
  }

  Future<int> insertPriceAlertRaw(Map<String, Object?> values) async {
    final db = await _open();
    return await db.insert('price_alerts', values);
  }

  Future<void> markPriceAlertNotified(int id) async {
    final db = await _open();
    await db.update('price_alerts', {'notified': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deletePriceAlert(int id) async {
    final db = await _open();
    await db.delete('price_alerts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> getLimitOrdersRaw({String? status}) async {
    final db = await _open();
    if (status != null) {
      return db.query('limit_orders', where: 'status = ?', whereArgs: [status], orderBy: 'created_at DESC');
    }
    return db.query('limit_orders', orderBy: 'created_at DESC');
  }

  Future<void> insertLimitOrderRaw(Map<String, Object?> values) async {
    final db = await _open();
    await db.insert('limit_orders', values);
  }

  Future<void> updateLimitOrderStatus(int id, String status) async {
    final db = await _open();
    await db.update('limit_orders', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteLimitOrder(int id) async {
    final db = await _open();
    await db.delete('limit_orders', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> getSavingsGoalsRaw() async {
    final db = await _open();
    return db.query('savings_goals', orderBy: 'created_at DESC');
  }

  Future<void> insertSavingsGoalRaw(Map<String, Object?> values) async {
    final db = await _open();
    await db.insert('savings_goals', values);
  }

  Future<void> updateSavingsGoalRaw(int id, Map<String, Object?> values) async {
    final db = await _open();
    await db.update('savings_goals', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSavingsGoal(int id) async {
    final db = await _open();
    await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }
}
