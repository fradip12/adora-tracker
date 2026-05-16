import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/theme/app_spacing.dart';
import '../managers/tracker_bloc.dart';
import '../widgets/c_home_coord_card.dart';
import '../widgets/c_home_map_section.dart';
import '../widgets/c_home_stats_mini.dart';
import '../widgets/c_home_tracking_chip.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final mapHeight = screenH * 0.3;

    return BlocBuilder<TrackerBloc, TrackerState>(
      builder: (context, state) {
        final active = state.mapOrNull(active: (s) => s);
        final position = active?.position;
        final isTracking = active?.isTracking ?? false;

        return Padding(
          padding: .all(context.m),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: .stretch,
              spacing: context.s,
              children: [
                Flexible(child: HomeTrackingChip(isTracking: isTracking)),
                Flexible(
                  flex: 3,
                  child: HomeMapSection(
                    height: mapHeight,
                    position: position,
                    trackPoints: active?.trackPoints ?? const [],
                  ),
                ),
                Flexible(flex: 2, child: HomeCoordCard(position: position)),
                Flexible(
                  child: HomeStatsMini(
                    points: active?.todayPoints ?? 0,
                    distanceM: active?.todayDistanceM ?? 0,
                    durationSeconds: active?.todayDurationSeconds ?? 0,
                  ),
                ),
                Flexible(
                  child: SizedBox(
                    height: MediaQuery.paddingOf(context).bottom + 88,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
