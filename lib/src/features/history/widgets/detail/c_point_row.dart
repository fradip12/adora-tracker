import 'package:flutter/material.dart';

import '../../../../core/components/theme/app_colors.dart';
import '../list/c_accuracy_badge.dart';

class CPointRow extends StatelessWidget {
  const CPointRow({
    required this.index,
    required this.time,
    required this.accuracy,
    required this.isFirst,
    required this.isLast,
    super.key,
    this.distM,
  });

  final int index;
  final String time;
  final double accuracy;
  final double? distM;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dotColor = isFirst
        ? AppColors.success
        : isLast
        ? AppColors.primaryDark
        : AppColors.border;

    return Container(
      padding: const .symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: .all(color: AppColors.border),
        borderRadius: .circular(12),
      ),
      child: Row(
        spacing: 10,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: dotColor.withValues(alpha: 0.12),
              shape: .circle,
            ),
            alignment: .center,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: .w700,
                color: isFirst || isLast ? dotColor : AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (distM != null)
            Text(
              '+${distM!.toStringAsFixed(0)} m',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          AccuracyBadge(accuracy: accuracy),
        ],
      ),
    );
  }
}
