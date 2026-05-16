import 'package:flutter/material.dart';

import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';

class HomeStatCard extends StatelessWidget {
  const HomeStatCard({
    required this.value,
    required this.label,
    this.unit,
    this.valueColor,
    super.key,
  });

  final String value;
  final String label;
  final String? unit;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .all(context.m),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: .all(color: AppColors.border),
        borderRadius: .circular(14),
      ),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisAlignment: .center,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                if (unit != null)
                  TextSpan(
                    text: unit,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.06 * 10,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
