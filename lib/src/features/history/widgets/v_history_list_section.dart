import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';
import '../../../core/data/database/app_database.dart';
import 'c_coordinate_list_item.dart';

class HistoryListSection extends StatelessWidget {
  const HistoryListSection({required this.records, this.onItemTap, super.key});

  final List<TrackingCoordinate> records;
  final VoidCallback? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(
        child: Text(
          context.t.history.empty,
          style: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
        ),
      );
    }

    return ListView.separated(
      padding: .zero,
      itemCount: records.length,
      separatorBuilder: (_, _) => context.xs.vSpace,
      itemBuilder: (_, index) => CoordinateListItem(
        record: records[index],
        isLatest: index == 0,
        onTap: onItemTap,
      ),
    );
  }
}
