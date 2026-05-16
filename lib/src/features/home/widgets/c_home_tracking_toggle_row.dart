import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';

class HomeTrackingToggleRow extends StatelessWidget {
  const HomeTrackingToggleRow({
    required this.isTracking,
    required this.onToggle,
    super.key,
  });

  final bool isTracking;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .all(context.m),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: .all(color: AppColors.border),
        borderRadius: .circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .center,
              children: [
                Text(
                  context.t.home.backgroundTracking,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: .w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  context.t.home.backgroundTrackingDesc,
                  style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Switch(
            value: isTracking,
            onChanged: (_) => onToggle(),
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.border,
            trackOutlineColor: .all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
