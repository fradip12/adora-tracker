import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:injectable/injectable.dart';

part 'app_database.g.dart';

@DataClassName('TrackingSession')
class TrackingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get startedTime => text()();
  TextColumn get stoppedTime => text().nullable()();
  IntColumn get duration => integer().nullable()();
}

@DataClassName('TrackingCoordinate')
class TrackingCoordinates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get parentId =>
      integer().references(TrackingSessions, #id, onDelete: KeyAction.cascade)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get timestamp => text()();
  TextColumn get accuracy => text()();
}

@singleton
@DriftDatabase(tables: [TrackingSessions, TrackingCoordinates])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'adaro_tracking'));

  @override
  int get schemaVersion => 1;
}

// — Session DAO —

extension TrackingSessionsDao on AppDatabase {
  Future<int> insertSession(String startedTime) => into(trackingSessions).insert(
        TrackingSessionsCompanion.insert(startedTime: startedTime),
      );

  Future<void> closeSession(int id) async {
    final row =
        await (select(trackingSessions)..where((t) => t.id.equals(id))).getSingle();
    final durationMs =
        DateTime.now().difference(DateTime.parse(row.startedTime)).inMilliseconds;
    await (update(trackingSessions)..where((t) => t.id.equals(id))).write(
      TrackingSessionsCompanion(
        stoppedTime: Value(DateTime.now().toIso8601String()),
        duration: Value(durationMs),
      ),
    );
  }

  Future<TrackingSession?> activeSession() =>
      (select(trackingSessions)..where((t) => t.stoppedTime.isNull()))
          .getSingleOrNull();

  Future<List<TrackingSession>> allSessions() =>
      (select(trackingSessions)
            ..orderBy([(t) => OrderingTerm.desc(t.id)]))
          .get();
}

// — Coordinate DAO —

extension TrackingCoordinatesDao on AppDatabase {
  Future<void> insertCoordinate({
    required int parentId,
    required double latitude,
    required double longitude,
    required String accuracy,
  }) =>
      into(trackingCoordinates).insert(
        TrackingCoordinatesCompanion.insert(
          parentId: parentId,
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now().toIso8601String(),
          accuracy: accuracy,
        ),
      );

  Stream<List<TrackingCoordinate>> watchSession(int sessionId) =>
      (select(trackingCoordinates)
            ..where((t) => t.parentId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
          .watch();

  Future<List<TrackingCoordinate>> coordsForSession(int sessionId) =>
      (select(trackingCoordinates)
            ..where((t) => t.parentId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
          .get();

  Future<List<TrackingCoordinate>> coordsByDateRange(DateTime from, DateTime to) =>
      (select(trackingCoordinates)
            ..where(
              (t) =>
                  t.timestamp.isBiggerOrEqualValue(from.toIso8601String()) &
                  t.timestamp.isSmallerThanValue(to.toIso8601String()),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
          .get();

  Future<List<TrackingCoordinate>> coordsToday() {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    return coordsByDateRange(dayStart, dayStart.add(const Duration(days: 1)));
  }

  Future<List<TrackingCoordinate>> allCoords() =>
      (select(trackingCoordinates)
            ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
          .get();
}
