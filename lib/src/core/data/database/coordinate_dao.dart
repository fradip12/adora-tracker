import 'package:injectable/injectable.dart';

import '../models/coordinate_record.dart';
import 'app_database.dart';

@lazySingleton
class CoordinateDao {
  CoordinateDao(this._db);

  final AppDatabase _db;

  Future<int> insert(CoordinateRecord record) =>
      _db.db.insert('coordinates', record.toMap());

  Future<List<CoordinateRecord>> queryByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final rows = await _db.db.query(
      'coordinates',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [
        from.millisecondsSinceEpoch,
        to.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp ASC',
    );
    return rows.map(CoordinateRecord.fromMap).toList();
  }

  Future<List<CoordinateRecord>> queryAll() async {
    final rows = await _db.db.query(
      'coordinates',
      orderBy: 'timestamp ASC',
    );
    return rows.map(CoordinateRecord.fromMap).toList();
  }

  Future<int> deleteAll() => _db.db.delete('coordinates');
}
