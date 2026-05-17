import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';
import '../../../core/extension/ext_misc.dart';

class BatteryWarningBox extends StatelessWidget {
  const BatteryWarningBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .all(context.m),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacityPercent(10),
        border: .all(color: AppColors.warning.withOpacityPercent(20)),
        borderRadius: .circular(context.m),
      ),
      child: Row(
        spacing: context.s,
        children: [
          const Icon(
            LucideIcons.triangleAlert,
            size: 18,
            color: Color(0xFFF59E0B),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF78350F),
                  height: 1.55,
                ),
                children: [
                  TextSpan(
                    text: '${context.t.settings.batteryNotice}: ',
                    style: const TextStyle(fontWeight: .w600),
                  ),
                  TextSpan(text: context.t.settings.batteryNoticeText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
