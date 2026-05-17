import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';

class CPillNavBar extends StatelessWidget {
  const CPillNavBar({
    required this.activeIndex,
    required this.onTabTap,
    super.key,
  });

  final int activeIndex;
  final ValueChanged<int> onTabTap;

  static const double barHeight = 52;

  static const _icons = [
    LucideIcons.layoutDashboard,
    LucideIcons.history,
    LucideIcons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;

    return SizedBox(
      height: barHeight + safeBottom + context.m,
      child: Align(
        alignment: .bottomCenter,
        child: Padding(
          padding: .only(bottom: safeBottom + context.s),
          child: Container(
            height: barHeight,
            padding: .all(context.xs),
            decoration: BoxDecoration(
              color: AppColors.navBg,
              borderRadius: .circular(context.xl),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                for (int i = 0; i < _icons.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  _NavItem(
                    icon: _icons[i],
                    active: activeIndex == i,
                    onTap: () => onTabTap(i),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 65,
        height: 38,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: .circular(19),
        ),
        child: Icon(
          icon,
          size: 18,
          color: active
              ? AppColors.navBg
              : Colors.white.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}
