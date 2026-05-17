import 'package:flutter/material.dart';

import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';
import '../../../data/settings/enums/tracking_interval.dart';

class IntervalSelector extends StatelessWidget {
  const IntervalSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final TrackingInterval selected;
  final ValueChanged<TrackingInterval> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .all(context.xxs),
      decoration: BoxDecoration(
        color: AppColors.offWhiteBg,
        border: .all(color: AppColors.border),
        borderRadius: .circular(context.s),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TrackingInterval.values.map((interval) {
          final isActive = interval == selected;

          return GestureDetector(
            onTap: () => onChanged(interval),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const .symmetric(horizontal: 13, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.surfaceWhite : Colors.transparent,
                borderRadius: .circular(8),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.black.withAlpha(23),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                interval.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? .w700 : .w500,
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
