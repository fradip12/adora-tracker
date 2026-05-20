import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/app_router.dart';
import '../../../core/extension/ext_overlays.dart';
import '../../home/managers/tracker_bloc.dart';
import '../../home/widgets/c_home_tracking_fab.dart';
import '../widgets/c_pill_nav_bar.dart';

@RoutePage()
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver {
  static const _routes = [HomeRoute(), HistoryRoute(), SettingsRoute()];
  int _activeIndex = 0;
  StackRouter? _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _router = context.router;
      _router?.addListener(_onRouteChanged);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _router?.removeListener(_onRouteChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<TrackerBloc>().add(.appLifecycleChanged(state));
  }

  void _onRouteChanged() {
    final path = _router?.currentPath ?? '';
    final index = path.contains('history')
        ? 1
        : path.contains('settings')
        ? 2
        : 0;

    if (_activeIndex != index) setState(() => _activeIndex = index);
  }

  void _onTabTap(int index) {
    setState(() => _activeIndex = index);

    context.replaceRoute(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TrackerBloc, TrackerState>(
      listenWhen: (prev, curr) {
        final was = prev.mapOrNull(active: (s) => s)?.isTracking ?? false;
        final now = curr.mapOrNull(active: (s) => s)?.isTracking ?? false;
        return was && !now;
      },
      listener: (context, _) =>
          context.showToast('Tracking completed', type: .success),
      child: Scaffold(
        extendBody: true,
        floatingActionButton: BlocBuilder<TrackerBloc, TrackerState>(
          builder: (context, state) {
            final isTracking =
                state.mapOrNull(active: (s) => s)?.isTracking ?? false;

            return HomeTrackingFab(
              isTracking: isTracking,
              onTap: () =>
                  context.read<TrackerBloc>().add(const .toggleTracking()),
            );
          },
        ),
        bottomNavigationBar: CPillNavBar(
          activeIndex: _activeIndex,
          onTabTap: _onTabTap,
        ),
        body: const AutoRouter(),
      ),
    );
  }
}
