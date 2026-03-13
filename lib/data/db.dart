// Локальная БД SQLite: таблицы расходов, операций обмена, портфеля (позиции и сделки).
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Единая точка доступа к БД. Версия 3: добавлены exchange_operations, portfolio_holdings, portfolio_transactions.
class AppDatabase {
  static const _dbName = 'fincontrol.db';
  /// При увеличении версии срабатывает [onUpgrade] (миграции).
  static const _dbVersion = 3;

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
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await db.execute('ALTER TABLE expenses ADD COLUMN image_path TEXT');
        }
        if (oldV < 3) {
          await _createExchangeAndPortfolioTables(db);
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
}
