import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// Простая SQLite-БД для расходов
class AppDatabase {
  static const _dbName = 'fin_control.db';
  static const _dbVersion = 1;

  static const table = 'expenses'; // id, title, amount, category, date, is_income

  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    final fullPath = p.join(dir, _dbName);
    _db = await openDatabase(
      fullPath,
      version: _dbVersion,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE $table (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            date INTEGER NOT NULL,
            is_income INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldV, newV) async {
        // миграции на будущее
      },
    );
    return _db!;
  }

  Future<List<Map<String, Object?>>> getAllRaw() async {
    final db = await _open();
    return db.query(table, orderBy: 'date DESC');
  }

  Future<void> insertRaw(Map<String, Object?> data) async {
    final db = await _open();
    await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateRaw(String id, Map<String, Object?> data) async {
    final db = await _open();
    await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteById(String id) async {
    final db = await _open();
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await _open();
    await db.delete(table);
  }
}
