import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._(this._db);

  final Database _db;
  Database get db => _db;

  static Future<AppDatabase> open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'adaro.db');
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE coordinates (
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude  REAL    NOT NULL,
            longitude REAL    NOT NULL,
            accuracy  REAL    NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_coordinates_timestamp ON coordinates(timestamp)',
        );
      },
    );
    return AppDatabase._(db);
  }
}
