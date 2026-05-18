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
  BoolColumn get isRecording => boolean().withDefault(const Constant(false))();
}

@DataClassName('TrackingCoordinate')
class TrackingCoordinates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get parentId => integer().references(
    TrackingSessions,
    #id,
    onDelete: KeyAction.cascade,
  )();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get timestamp => text()();
  TextColumn get accuracy => text()();
}

@singleton
@DriftDatabase(tables: [TrackingSessions, TrackingCoordinates])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'adora_tracking'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(trackingSessions, trackingSessions.isRecording);
      }
    },
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );
}

// — Session DAO —

extension TrackingSessionsDao on AppDatabase {
  Future<int> insertSession(String startedTime) =>
      into(trackingSessions).insert(
        TrackingSessionsCompanion.insert(
          startedTime: startedTime,
          isRecording: const Value(true),
        ),
      );

  Future<void> closeSession(int id) async {
    final row = await (select(
      trackingSessions,
    )..where((t) => t.id.equals(id))).getSingle();
    final stoppedAt = DateTime.now();
    final durationMs = stoppedAt
        .difference(DateTime.parse(row.startedTime))
        .inMilliseconds;
    await (update(trackingSessions)..where((t) => t.id.equals(id))).write(
      TrackingSessionsCompanion(
        stoppedTime: Value(stoppedAt.toIso8601String()),
        duration: Value(durationMs),
        isRecording: const Value(false),
      ),
    );
  }

  Future<TrackingSession?> activeSession() => (select(
    trackingSessions,
  )..where((t) => t.isRecording.equals(true))).getSingleOrNull();

  Future<List<TrackingSession>> allSessions() =>
      (select(trackingSessions)..orderBy([(t) => .desc(t.id)])).get();

  Future<List<TrackingSession>> sessionsByDateRange(
    DateTime from,
    DateTime to,
  ) =>
      (select(trackingSessions)
            ..where(
              (t) =>
                  t.startedTime.isBiggerOrEqualValue(from.toIso8601String()) &
                  t.startedTime.isSmallerThanValue(to.toIso8601String()),
            )
            ..orderBy([(t) => .desc(t.id)]))
          .get();

  Future<void> deleteAll() async {
    await delete(trackingCoordinates).go();
    await delete(trackingSessions).go();
  }
}

// — Coordinate DAO —

extension TrackingCoordinatesDao on AppDatabase {
  Future<void> insertCoordinate({
    required int parentId,
    required double latitude,
    required double longitude,
    required String accuracy,
  }) => into(trackingCoordinates).insert(
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
            ..orderBy([(t) => .asc(t.timestamp)]))
          .watch();

  Future<List<TrackingCoordinate>> coordsForSession(int sessionId) =>
      (select(trackingCoordinates)
            ..where((t) => t.parentId.equals(sessionId))
            ..orderBy([(t) => .asc(t.timestamp)]))
          .get();

  Future<List<TrackingCoordinate>> coordsByDateRange(
    DateTime from,
    DateTime to,
  ) =>
      (select(trackingCoordinates)
            ..where(
              (t) =>
                  t.timestamp.isBiggerOrEqualValue(from.toIso8601String()) &
                  t.timestamp.isSmallerThanValue(to.toIso8601String()),
            )
            ..orderBy([(t) => .asc(t.timestamp)]))
          .get();

  Stream<List<TrackingCoordinate>> watchCoordsToday() {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final from = dayStart.toIso8601String();
    final to = dayStart.add(const Duration(days: 1)).toIso8601String();
    return (select(trackingCoordinates)
          ..where(
            (t) =>
                t.timestamp.isBiggerOrEqualValue(from) &
                t.timestamp.isSmallerThanValue(to),
          )
          ..orderBy([(t) => .asc(t.timestamp)]))
        .watch();
  }

  Future<List<TrackingCoordinate>> allCoords() =>
      (select(trackingCoordinates)..orderBy([(t) => .asc(t.timestamp)])).get();
}
