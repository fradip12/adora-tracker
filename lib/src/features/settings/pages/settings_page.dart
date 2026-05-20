import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';
import '../../../core/config/app_di.dart';
import '../../../data/tracker/services/tracker_service.dart';
import '../../root/widgets/c_pill_nav_bar.dart';
import '../managers/settings_bloc.dart';
import '../widgets/c_battery_warning_box.dart';
import '../widgets/c_danger_button.dart';
import '../widgets/c_settings_section_label.dart';
import '../widgets/v_settings_language_section.dart';
import '../widgets/v_settings_permissions_section.dart';
import '../widgets/v_settings_tracking_section.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<SettingsBloc>()..add(const SettingsEvent.init()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == .resumed) {
      context.read<SettingsBloc>().add(const .refreshPermissions());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final active = state.mapOrNull(active: (s) => s);

        return SafeArea(
          bottom: false,
          child: Padding(
            padding: .all(context.m),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: .start,
                spacing: context.s,
                children: [
                  Text(
                    context.t.settings.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.025 * 28,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SettingsSectionLabel(context.t.settings.sectionPermissions),
                  SettingsPermissionsSection(
                    locationGranted: active?.locationGranted ?? false,
                    notificationGranted: active?.notificationGranted ?? false,
                    batteryOptimizationDisabled:
                        active?.batteryOptimizationDisabled ?? false,
                  ),

                  SettingsSectionLabel(context.t.settings.sectionTracking),
                  SettingsTrackingSection(
                    interval: active?.interval ?? .s30,
                    backgroundTracking: active?.backgroundTracking ?? true,
                    terminatedState: active?.terminatedState ?? false,
                    persistentNotification:
                        active?.persistentNotification ?? true,
                    showTerminatedState:
                        locator<TrackerService>().supportsTerminatedState,
                    onIntervalChanged: (v) => context.read<SettingsBloc>().add(
                      SettingsEvent.updateInterval(v),
                    ),
                    onToggleBackgroundTracking: () => context
                        .read<SettingsBloc>()
                        .add(const .toggleBackgroundTracking()),
                    onToggleTerminatedState: () => context
                        .read<SettingsBloc>()
                        .add(const .toggleTerminatedState()),
                    onTogglePersistentNotification: () => context
                        .read<SettingsBloc>()
                        .add(const .togglePersistentNotification()),
                  ),
                  if (active?.interval == .s10) const BatteryWarningBox(),

                  SettingsSectionLabel(context.t.settings.sectionLanguage),
                  SettingsLanguageSection(
                    locale: active?.locale ?? .english,
                    onLocaleChanged: (v) => context.read<SettingsBloc>().add(
                      SettingsEvent.changeLocale(v),
                    ),
                  ),

                  DangerButton(
                    onConfirm: () {
                      context.read<SettingsBloc>().add(const .clearData());
                    },
                  ),

                  SizedBox(
                    height:
                        MediaQuery.viewPaddingOf(context).bottom +
                        CPillNavBar.barHeight +
                        64,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
