import 'package:flutter/material.dart';

import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';
import 'c_settings_icon_box.dart';

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.name,
    required this.description,
    required this.trailing,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String name;
  final String description;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: .all(context.s),
        child: Row(
          spacing: 12,
          children: [
            SettingsIconBox(
              icon: icon,
              bgColor: iconBgColor,
              iconColor: iconColor,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                spacing: 2,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: .w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
