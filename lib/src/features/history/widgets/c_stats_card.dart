import 'package:flutter/material.dart';

import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({
    required this.value,
    required this.label,
    this.valueColor = AppColors.textPrimary,
    super.key,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .all(context.m),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: .all(color: AppColors.border),
        borderRadius: .circular(context.m),
      ),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 4,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: .w700,
              fontFamily: 'monospace',
              color: valueColor,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: .w500,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
