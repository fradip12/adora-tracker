import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/extension/ext_misc.dart';
import 'c_perm_badge.dart';
import 'c_settings_group.dart';
import 'c_settings_row.dart';

class SettingsPermissionsSection extends StatelessWidget {
  const SettingsPermissionsSection({
    required this.locationGranted,
    required this.notificationGranted,
    required this.batteryOptimizationDisabled,
    super.key,
  });

  final bool locationGranted;
  final bool notificationGranted;
  final bool batteryOptimizationDisabled;

  Widget _chevron() => const Icon(
    LucideIcons.chevronRight,
    size: 16,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      children: [
        SettingsRow(
          icon: LucideIcons.mapPin,
          iconBgColor: AppColors.primaryLight,
          iconColor: AppColors.primaryDark,
          name: context.t.settings.permLocation,
          description: context.t.settings.permLocationDesc,
          onTap: openAppSettings,
          trailing: Row(
            mainAxisSize: .min,
            spacing: 8,
            children: [
              PermBadge(status: locationGranted ? .allowed : .denied),
              _chevron(),
            ],
          ),
        ),

        SettingsRow(
          icon: LucideIcons.bell,
          iconBgColor: AppColors.primaryLight,
          iconColor: AppColors.primaryDark,
          name: context.t.settings.permNotification,
          description: context.t.settings.permNotificationDesc,
          onTap: openAppSettings,
          trailing: Row(
            mainAxisSize: .min,
            spacing: 8,
            children: [
              PermBadge(status: notificationGranted ? .allowed : .denied),
              _chevron(),
            ],
          ),
        ),

        if (Platform.isAndroid)
          SettingsRow(
            icon: LucideIcons.batteryCharging,
            iconBgColor: AppColors.warning.withOpacityPercent(30),
            iconColor: AppColors.warning,
            name: context.t.settings.permBattery,
            description: context.t.settings.permBatteryDesc,
            onTap: openAppSettings,
            trailing: Row(
              mainAxisSize: .min,
              spacing: 8,
              children: [
                PermBadge(
                  status: batteryOptimizationDisabled ? .allowed : .restricted,
                ),
                _chevron(),
              ],
            ),
          ),
      ],
    );
  }
}
