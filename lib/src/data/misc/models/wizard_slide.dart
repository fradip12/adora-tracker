import 'package:flutter/material.dart';

import '../../../core/components/theme/app_colors.dart';

class SlideData {
  const SlideData({
    required this.bg,
    required this.btn,
    required this.icon,
    required this.dark,
  });

  final Color bg;
  final Color btn;
  final Color icon;
  final bool dark;
}

/// Slide 0 = location permission, Slide 1 = ready screen (same for all platforms).
const wizardSlides = [
  SlideData(
    bg: AppColors.primaryDark,
    btn: Colors.white,
    icon: AppColors.primaryDark,
    dark: true,
  ),
  SlideData(
    bg: Colors.white,
    btn: AppColors.primaryDark,
    icon: Colors.white,
    dark: false,
  ),
];
