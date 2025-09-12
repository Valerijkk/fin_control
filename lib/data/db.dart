import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static const _dbName = 'fin_control.db';
  static const _dbVersion = 2; // ↑ повысили версию, добавили image_path

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        // таблица сразу с image_path
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // миграция: добавляем колонку image_path, если базы старой версии
        if (oldVersion < 2) {
          // проверим, нет ли уже этой колонки
          final hasImagePath = await _hasColumn(db, 'expenses', 'image_path');
          if (!hasImagePath) {
            await db.execute('ALTER TABLE expenses ADD COLUMN image_path TEXT');
          }
        }
      },
    );
  }

  /// Проверка наличия колонки в таблице (для надёжных миграций)
  Future<bool> _hasColumn(Database db, String table, String col) async {
    final res = await db.rawQuery('PRAGMA table_info($table)');
    for (final row in res) {
      if ((row['name'] as String).toLowerCase() == col.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  // ===== CRUD низкоуровневыми Map'ами, как у тебя в AppState =====

  Future<List<Map<String, Object?>>> getAllRaw() async {
    final db = await database;
    // сортировка по дате по убыванию (новые сверху)
    return db.query('expenses', orderBy: 'date DESC');
  }

  Future<void> insertRaw(Map<String, Object?> data) async {
    final db = await database;
    // на случай повторной вставки одной и той же id — заменяем
    await db.insert(
      'expenses',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateRaw(String id, Map<String, Object?> data) async {
    final db = await database;
    await db.update(
      'expenses',
      data,
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteById(String id) async {
    final db = await database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // опционально: очистка таблицы
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('expenses');
  }
}
