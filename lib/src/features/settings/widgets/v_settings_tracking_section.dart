import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../data/settings/enums/tracking_interval.dart';
import 'c_interval_selector.dart';
import 'c_settings_group.dart';
import 'c_settings_row.dart';

class SettingsTrackingSection extends StatelessWidget {
  const SettingsTrackingSection({
    required this.interval,
    required this.backgroundTracking,
    required this.terminatedState,
    required this.persistentNotification,
    required this.onIntervalChanged,
    required this.onToggleBackgroundTracking,
    required this.onToggleTerminatedState,
    required this.onTogglePersistentNotification,
    super.key,
  });

  final TrackingInterval interval;
  final bool backgroundTracking;
  final bool terminatedState;
  final bool persistentNotification;
  final ValueChanged<TrackingInterval> onIntervalChanged;
  final VoidCallback onToggleBackgroundTracking;
  final VoidCallback onToggleTerminatedState;
  final VoidCallback onTogglePersistentNotification;

  Switch _switch(bool value, VoidCallback onToggle) => Switch(
    value: value,
    onChanged: (_) => onToggle(),
    activeThumbColor: Colors.white,
    activeTrackColor: AppColors.primary,
    inactiveThumbColor: Colors.white,
    inactiveTrackColor: AppColors.border,
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  );

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      children: [
        SettingsRow(
          icon: LucideIcons.clock,
          iconBgColor: AppColors.primaryLight,
          iconColor: AppColors.primaryDark,
          name: context.t.settings.trackingInterval,
          description: context.t.settings.trackingIntervalDesc,
          trailing: IntervalSelector(
            selected: interval,
            onChanged: onIntervalChanged,
          ),
        ),
        SettingsRow(
          icon: LucideIcons.layoutGrid,
          iconBgColor: AppColors.primaryLight,
          iconColor: AppColors.primaryDark,
          name: context.t.settings.backgroundTracking,
          description: context.t.settings.backgroundTrackingDesc,
          trailing: _switch(backgroundTracking, onToggleBackgroundTracking),
        ),
        SettingsRow(
          icon: LucideIcons.bookmark,
          iconBgColor: AppColors.primaryLight,
          iconColor: AppColors.primaryDark,
          name: context.t.settings.terminatedState,
          description: context.t.settings.terminatedStateDesc,
          trailing: _switch(terminatedState, onToggleTerminatedState),
        ),
        SettingsRow(
          icon: LucideIcons.layoutList,
          iconBgColor: AppColors.primaryLight,
          iconColor: AppColors.primaryDark,
          name: context.t.settings.persistentNotification,
          description: context.t.settings.persistentNotificationDesc,
          trailing: _switch(
            persistentNotification,
            onTogglePersistentNotification,
          ),
        ),
      ],
    );
  }
}
