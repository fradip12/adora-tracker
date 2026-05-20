import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';
import '../../../data/settings/enums/perm_badge_status.dart';

class PermBadge extends StatelessWidget {
  const PermBadge({required this.status, super.key});

  final PermBadgeStatus status;

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, label) = switch (status) {
      .allowed => (
        AppColors.primaryLight,
        AppColors.primaryDark,
        context.t.settings.statusAllowed,
      ),
      .denied => (
        AppColors.primaryLight,
        AppColors.danger,
        context.t.settings.statusDenied,
      ),
      .restricted => (
        AppColors.primaryLight,
        AppColors.warning,
        context.t.settings.statusRestricted,
      ),
    };

    return Container(
      padding: const .symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: .circular(context.s),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: .w700,
          color: textColor,
          letterSpacing: 0.02 * 11,
        ),
      ),
    );
  }
}
