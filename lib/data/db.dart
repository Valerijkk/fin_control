import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _dbName = 'fincontrol.db';
  static const _dbVersion = 2; // ↑ увеличили для image_path

  Database? _db;

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
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await db.execute('ALTER TABLE expenses ADD COLUMN image_path TEXT');
        }
      },
    );
    return _db!;
  }

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
}
