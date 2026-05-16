import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';
import '../../../core/config/app_di.dart';
import '../../../core/config/app_router.dart';
import '../../../core/extension/ext_overlays.dart';
import '../../home/managers/tracker_bloc.dart';
import '../../home/widgets/c_home_tracking_fab.dart';
import '../widgets/c_pill_nav_bar.dart';

@RoutePage()
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return BlocProvider(
      create: (_) => locator<TrackerBloc>()..add(const TrackerEvent.init()),
      child: BlocListener<TrackerBloc, TrackerState>(
        listenWhen: (prev, curr) {
          final was = prev.mapOrNull(active: (s) => s)?.isTracking ?? false;
          final now = curr.mapOrNull(active: (s) => s)?.isTracking ?? false;
          return was && !now;
        },
        listener: (context, _) =>
            context.showToast('Tracking completed', type: .success),
        child: Stack(
          children: [
            AutoTabsScaffold(
              routes: const [HomeRoute(), HistoryRoute(), SettingsRoute()],
              extendBody: true,
              backgroundColor: AppColors.surfaceWhite,
              transitionBuilder: (context, child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              bottomNavigationBuilder: (_, tabsRouter) =>
                  CPillNavBar(tabsRouter: tabsRouter),
              resizeToAvoidBottomInset: true,
            ),
            Positioned(
              bottom: bottomInset + 76,
              right: context.m,
              child: Center(
                child: BlocBuilder<TrackerBloc, TrackerState>(
                  builder: (context, state) {
                    final isTracking =
                        state.mapOrNull(active: (s) => s)?.isTracking ?? false;

                    return HomeTrackingFab(
                      isTracking: isTracking,
                      onTap: () => context.read<TrackerBloc>().add(
                        const TrackerEvent.toggleTracking(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
