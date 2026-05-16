import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';
import 'c_home_stat_card.dart';

class HomeStatsMini extends StatelessWidget {
  const HomeStatsMini({
    required this.points,
    required this.distanceM,
    required this.durationSeconds,
    super.key,
  });

  final int points;
  final double distanceM;
  final int durationSeconds;

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h${m.toString().padLeft(2, '0')}m';
    if (m > 0) return '${m}m${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final distKm = distanceM / 1000;

    return Row(
      spacing: context.s,
      children: [
        Expanded(
          child: HomeStatCard(value: '$points', label: context.t.home.statPoints),
        ),
        Expanded(
          child: HomeStatCard(
            value: distKm >= 0.1
                ? distKm.toStringAsFixed(1)
                : (distanceM.round()).toString(),
            unit: distKm >= 0.1 ? 'km' : 'm',
            label: context.t.home.statToday,
            valueColor: AppColors.primaryDark,
          ),
        ),
        Expanded(
          child: HomeStatCard(
            value: _formatDuration(durationSeconds),
            label: context.t.home.statDuration,
          ),
        ),
      ],
    );
  }
}
