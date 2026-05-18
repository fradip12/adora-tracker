import 'package:flutter/material.dart';

import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';

class HomeCoordItem extends StatelessWidget {
  const HomeCoordItem({
    required this.label,
    required this.value,
    required this.suffix,
    super.key,
  });

  final String label;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      spacing: context.xs,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: .w600,
            letterSpacing: 0.07 * 10,
            color: AppColors.textTertiary,
          ),
        ),

        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 21,
                  fontWeight: .w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              TextSpan(
                text: suffix,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: .w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
