import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';

class HomeTrackingChip extends StatefulWidget {
  const HomeTrackingChip({required this.isTracking, super.key});

  final bool isTracking;

  @override
  State<HomeTrackingChip> createState() => _HomeTrackingChipState();
}

class _HomeTrackingChipState extends State<HomeTrackingChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTracking = widget.isTracking;
    return Container(
      padding: const .symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isTracking
            ? AppColors.primaryBg
            : AppColors.border.withValues(alpha: 0.4),
        borderRadius: .circular(14),
      ),
      child: Row(
        spacing: context.s,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isTracking)
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) => Transform.scale(
                      scale: 1 + _pulse.value * 1.4,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: .circle,
                          color: AppColors.primary.withValues(
                            alpha: 0.4 * (1 - _pulse.value),
                          ),
                        ),
                      ),
                    ),
                  ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: .circle,
                    color: isTracking
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          Text(
            isTracking
                ? context.t.home.trackingActive
                : context.t.home.trackingPaused,
            style: TextStyle(
              fontSize: 14,
              fontWeight: .w600,
              color: isTracking
                  ? AppColors.primaryDark
                  : AppColors.textSecondary,
            ),
          ),

          const Spacer(),
          if (isTracking)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: .circle,
                border: Border.all(color: AppColors.primary),
              ),
              child: const Icon(
                Icons.check,
                size: 13,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
