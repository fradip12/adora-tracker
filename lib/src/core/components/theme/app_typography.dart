import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

extension AppTypography on BuildContext {
  static const String _fontFamily = 'Inter';

  TextStyle get heading1 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: fsp(36),
    fontWeight: .w800,
    height: 1.15,
    letterSpacing: -1,
    color: AppColors.textPrimary,
  );

  TextStyle get heading3 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: fsp(24),
    fontWeight: .bold,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  TextStyle get bodyMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: fsp(16),
    fontWeight: .w500,
    color: AppColors.textPrimary,
  );

  TextStyle get bodySmall => TextStyle(
    fontFamily: _fontFamily,
    fontSize: fsp(12),
    fontWeight: .normal,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  TextStyle get caption => TextStyle(
    fontFamily: _fontFamily,
    fontSize: fsp(14),
    fontWeight: .normal,
    color: AppColors.textSecondary,
  );

  TextStyle get buttonText => TextStyle(
    fontFamily: _fontFamily,
    fontSize: fsp(14),
    fontWeight: .w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );
}
