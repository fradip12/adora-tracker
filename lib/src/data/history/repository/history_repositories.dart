import 'package:injectable/injectable.dart';

import '../../../core/data/database/app_database.dart';
import '../../../core/models/result.dart';
import '../enums/history_filter.dart';
import '../models/session_summary.dart';
import 'history_repository.dart';

@LazySingleton(as: HistoryRepository)
class HistoryRepositoryImpl implements HistoryRepository {
  final AppDatabase _db;

  HistoryRepositoryImpl(this._db);

  @override
  Future<Result<List<SessionSummary>>> fetchSummaries(
    HistoryFilter filter,
  ) async {
    try {
      final rawSessions = await _fetchSessions(filter);
      final summaries = await Future.wait(
        rawSessions.map((s) async {
          final coords = await _db.coordsForSession(s.id);
          return SessionSummary(
            session: s,
            coordinates: coords,
            distanceKm: SessionSummary.computeDistanceKm(coords),
          );
        }),
      );
      return Result.ok(summaries);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<List<TrackingSession>> _fetchSessions(HistoryFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return switch (filter) {
      .today => _db.sessionsByDateRange(
        today,
        today.add(const Duration(days: 1)),
      ),
      .yesterday => _db.sessionsByDateRange(
        today.subtract(const Duration(days: 1)),
        today,
      ),
      .thisWeek => _db.sessionsByDateRange(
        today.subtract(Duration(days: today.weekday - 1)),
        today.add(const Duration(days: 1)),
      ),
      .all => _db.allSessions(),
    };
  }
}
