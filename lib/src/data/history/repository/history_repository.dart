import '../../../core/models/result.dart';
import '../enums/history_filter.dart';
import '../models/session_summary.dart';

abstract class HistoryRepository {
  Future<Result<List<SessionSummary>>> fetchSummaries(HistoryFilter filter);
}
