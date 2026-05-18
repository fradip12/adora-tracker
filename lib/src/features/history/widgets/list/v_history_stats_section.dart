import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/components/theme/app_colors.dart';
import '../../../../core/components/theme/app_spacing.dart';
import 'c_stats_card.dart';

class HistoryStatsSection extends StatelessWidget {
  const HistoryStatsSection({
    required this.pointCount,
    required this.distanceKm,
    required this.avgAccuracy,
    super.key,
  });

  final int pointCount;
  final double distanceKm;
  final double avgAccuracy;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.s,
      children: [
        Expanded(
          child: StatsCard(
            value: pointCount.toString(),
            label: context.t.history.statPoints,
          ),
        ),
        Expanded(
          child: StatsCard(
            value: distanceKm.toStringAsFixed(1),
            label: context.t.history.statDistance,
            valueColor: AppColors.primaryDark,
          ),
        ),
        Expanded(
          child: StatsCard(
            value: context.t.history.accuracyValue(
              meters: avgAccuracy.toStringAsFixed(0),
            ),
            label: context.t.history.statAccuracy,
          ),
        ),
      ],
    );
  }
}
