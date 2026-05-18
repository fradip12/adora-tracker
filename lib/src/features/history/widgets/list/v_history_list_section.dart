import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/components/theme/app_colors.dart';
import '../../../../core/components/theme/app_spacing.dart';
import '../../../../data/history/models/session_summary.dart';
import 'c_coordinate_list_item.dart';

class HistoryListSection extends StatelessWidget {
  const HistoryListSection({
    required this.sessions,
    required this.onItemTap,
    super.key,
  });

  final List<SessionSummary> sessions;
  final void Function(SessionSummary) onItemTap;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Text(
          context.t.history.empty,
          style: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
        ),
      );
    }

    return ListView.separated(
      padding: .zero,
      itemCount: sessions.length,
      separatorBuilder: (_, _) => context.xs.vSpace,
      itemBuilder: (_, index) => SessionListItem(
        summary: sessions[index],
        isLatest: index == 0,
        onTap: () => onItemTap(sessions[index]),
      ),
    );
  }
}
