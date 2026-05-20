import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/components/interactive/global_animated_switcher.dart';
import '../../../core/components/interactive/global_button.dart';
import '../../../core/components/theme/app_spacing.dart';
import '../../../core/components/theme/app_typography.dart';
import '../../../data/settings/models/permission.dart';

class PermissionPrompter extends StatefulWidget {
  const PermissionPrompter({
    required this.background,
    required this.foreground,
    required this.index,
    required this.granted,
    required this.onAllow,
    super.key,
  });

  final int index;
  final Color background;
  final Color foreground;
  final bool granted;
  final VoidCallback onAllow;

  @override
  State<PermissionPrompter> createState() => PermissionPrompterState();
}

class PermissionPrompterState extends State<PermissionPrompter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _stagger(double start, double end, Widget child) {
    final anim = CurvedAnimation(
      parent: _ctrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeScaleTransition(animation: anim, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final data = (widget.index == 1)
        ? notificationPermission(context)
        : locationPermission(context);

    return Column(
      mainAxisSize: .min,
      mainAxisAlignment: .center,
      spacing: context.m,
      children: [
        _stagger(
          0,
          0.55,
          Container(
            padding: .all(context.m),
            decoration: BoxDecoration(
              color: widget.foreground,
              borderRadius: .circular(context.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(data.icon, color: widget.background),
          ),
        ),
        _stagger(
          0.15,
          0.65,
          Text(
            data.title,
            textAlign: .center,
            style: context.heading3.copyWith(color: widget.foreground),
          ),
        ),
        _stagger(
          0.30,
          0.80,
          Text(
            data.description,
            textAlign: .center,
            style: context.bodySmall.copyWith(color: widget.foreground),
          ),
        ),
        GlobalAnimatedSwitcher(
          useSizeTransition: false,
          duration: const Duration(milliseconds: 350),
          reverseDuration: const Duration(milliseconds: 200),
          child: widget.granted
              ? Container(
                  key: const ValueKey('granted'),
                  height: context.buttonHeight,
                  width: context.buttonHeight,
                  decoration: BoxDecoration(
                    color: widget.foreground,
                    borderRadius: .circular(context.radiusLarge),
                  ),
                  alignment: .center,
                  child: Icon(
                    LucideIcons.check,
                    color: widget.background,
                    size: 26,
                  ),
                )
              : GlobalButton(
                  key: const ValueKey('allow'),
                  onPressed: widget.onAllow,
                  isExpanded: false,
                  color: widget.foreground,
                  label: data.button,
                  borderRadius: BorderRadius.circular(context.radiusLarge),
                  textColor: widget.background,
                ),
        ),
      ],
    );
  }
}
