import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';
import '../../../core/config/app_di.dart';
import '../../../core/config/app_router.dart';
import '../../root/widgets/c_pill_nav_bar.dart';
import '../managers/history_bloc.dart';
import '../widgets/list/c_filter_chip_bar.dart';
import '../widgets/list/v_history_list_section.dart';
import '../widgets/list/v_history_stats_section.dart';

@RoutePage()
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<HistoryBloc>()..add(const HistoryEvent.load()),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        final active = state.mapOrNull(active: (s) => s);
        final loading = state.mapOrNull(loading: (s) => s);
        final currentFilter = active?.filter ?? loading?.filter ?? .today;

        return Scaffold(
          backgroundColor: AppColors.offWhiteBg,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                _HistoryHeader(
                  onRefresh: () =>
                      context.read<HistoryBloc>().add(const .refresh()),
                ),

                Padding(
                  padding: .symmetric(horizontal: context.l),
                  child: FilterChipBar(
                    active: currentFilter,
                    onChanged: (f) =>
                        context.read<HistoryBloc>().add(.filterChanged(f)),
                  ),
                ),

                if (active != null) ...[
                  Padding(
                    padding: .fromLTRB(
                      context.l,
                      context.m,
                      context.l,
                      context.m,
                    ),
                    child: HistoryStatsSection(
                      pointCount: active.totalPoints,
                      distanceKm: active.totalDistanceKm,
                      avgAccuracy: active.avgAccuracy,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: .symmetric(horizontal: context.l),
                      child: HistoryListSection(
                        sessions: active.sessions,
                        onItemTap: (summary) {
                          context.router.root.push(
                            HistoryDetailRoute(records: summary.coordinates),
                          );
                        },
                      ),
                    ),
                  ),
                ] else
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),

                SizedBox(
                  height:
                      MediaQuery.viewPaddingOf(context).bottom +
                      CPillNavBar.barHeight,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .fromLTRB(context.l, context.xs, context.l, context.m),
      child: Row(
        spacing: context.xxs,
        children: [
          Expanded(
            child: Text(
              context.t.history.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: .w700,
                letterSpacing: -0.025 * 28,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _IconButton(icon: LucideIcons.refreshCw, onTap: onRefresh),
          const _IconButton(icon: LucideIcons.arrowDownUp),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          border: .all(color: AppColors.border),
          borderRadius: .circular(12),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}
