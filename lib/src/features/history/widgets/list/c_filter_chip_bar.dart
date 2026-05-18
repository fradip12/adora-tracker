import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/components/theme/app_colors.dart';
import '../../../../core/components/theme/app_spacing.dart';
import '../../../../data/history/enums/history_filter.dart';

class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    required this.active,
    required this.onChanged,
    super.key,
  });

  final HistoryFilter active;
  final ValueChanged<HistoryFilter> onChanged;

  String _label(BuildContext context, HistoryFilter filter) => switch (filter) {
    .today => context.t.history.filterToday,
    .yesterday => context.t.history.filterYesterday,
    .thisWeek => context.t.history.filterThisWeek,
    .all => context.t.history.filterAll,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: .horizontal,
      child: Row(
        spacing: 8,
        children: HistoryFilter.values
            .map(
              (f) => _Chip(
                label: _label(context, f),
                isActive: active == f,
                onTap: () => onChanged(f),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: .symmetric(horizontal: context.m, vertical: context.xs),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceWhite,
          border: .all(color: isActive ? AppColors.primary : AppColors.border),
          borderRadius: .circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? .w600 : .w500,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
