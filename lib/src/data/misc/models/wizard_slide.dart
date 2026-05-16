import 'dart:io';

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

const _locationSlide = SlideData(
  bg: AppColors.primaryDark,
  btn: Colors.white,
  icon: AppColors.primaryDark,
  dark: true,
);

const _notificationSlide = SlideData(
  bg: AppColors.primary,
  btn: Colors.white,
  icon: AppColors.primary,
  dark: true,
);

const _readySlide = SlideData(
  bg: Colors.white,
  btn: AppColors.primaryDark,
  icon: Colors.white,
  dark: false,
);

List<SlideData> get wizardSlides => [
  _locationSlide,
  if (Platform.isIOS) _notificationSlide,
  _readySlide,
];
