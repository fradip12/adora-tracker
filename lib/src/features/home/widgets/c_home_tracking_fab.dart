import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/components/theme/app_colors.dart';

class HomeTrackingFab extends StatelessWidget {
  const HomeTrackingFab({
    required this.isTracking,
    required this.onTap,
    super.key,
  });

  final bool isTracking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isTracking ? AppColors.danger : AppColors.primary,
          shape: .circle,
          boxShadow: [
            BoxShadow(
              color: (isTracking ? AppColors.danger : AppColors.primary)
                  .withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          isTracking ? LucideIcons.square : LucideIcons.play,
          color: AppColors.surfaceWhite,
          size: 26,
        ),
      ),
    );
  }
}
