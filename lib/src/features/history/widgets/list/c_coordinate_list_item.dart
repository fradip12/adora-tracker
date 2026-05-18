import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/components/theme/app_colors.dart';
import '../../../../data/history/models/session_summary.dart';
import 'c_accuracy_badge.dart';

class SessionListItem extends StatelessWidget {
  const SessionListItem({
    required this.summary,
    required this.isLatest,
    this.onTap,
    super.key,
  });

  final SessionSummary summary;
  final bool isLatest;
  final VoidCallback? onTap;

  static final _dateFormat = DateFormat('dd MMM yyyy, h:mm a');

  String _duration() {
    final ms = summary.session.duration;
    if (ms == null) return '--';
    final d = Duration(milliseconds: ms);
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    return '${d.inSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final startLabel = _dateFormat.format(
      DateTime.parse(summary.session.startedTime),
    );
    final durationLabel = _duration();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          border: .all(color: AppColors.border),
          borderRadius: .circular(15),
        ),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                spacing: 4,
                children: [
                  Text(
                    startLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: .w500,
                      fontFamily: 'monospace',
                      color: AppColors.textPrimary,
                    ),
                    overflow: .ellipsis,
                  ),
                  Row(
                    spacing: 6,
                    children: [
                      Text(
                        '${summary.pointCount} pts · $durationLabel',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      if (summary.coordinates.isNotEmpty)
                        AccuracyBadge(accuracy: summary.avgAccuracyMeters),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              size: 14,
              color: AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}
