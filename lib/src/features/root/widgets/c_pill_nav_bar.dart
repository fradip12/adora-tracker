import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/components/theme/app_colors.dart';

class CPillNavBar extends StatelessWidget {
  const CPillNavBar({required this.tabsRouter, super.key});

  final TabsRouter tabsRouter;

  static const _icons = [
    LucideIcons.layoutDashboard,
    LucideIcons.history,
    LucideIcons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: .bottomCenter,
        child: Container(
          height: 52,
          padding: const .all(7),
          decoration: BoxDecoration(
            color: AppColors.navBg,
            borderRadius: .circular(26),
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
                  active: tabsRouter.activeIndex == i,
                  onTap: () => tabsRouter.setActiveIndex(i),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 65,
        height: 38,
        decoration: BoxDecoration(
          color: widget.active ? Colors.white : Colors.transparent,
          borderRadius: .circular(19),
        ),
        child: Icon(
          widget.icon,
          size: 18,
          color: widget.active
              ? AppColors.navBg
              : Colors.white.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}
