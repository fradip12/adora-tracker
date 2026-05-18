import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/data/database/app_database.dart';
import '../../../data/tracker/enums/gps_accuracy.dart';
import 'c_accuracy_badge.dart';

class CoordinateListItem extends StatelessWidget {
  const CoordinateListItem({
    required this.record,
    required this.isLatest,
    this.onTap,
    super.key,
  });

  final TrackingCoordinate record;
  final bool isLatest;
  final VoidCallback? onTap;

  static final _timeFormat = DateFormat('h:mm a');

  String _relativeTime(BuildContext context) {
    final diff = DateTime.now().difference(DateTime.parse(record.timestamp));
    if (diff.inSeconds < 60) return context.t.history.justNow;
    if (diff.inMinutes < 60) {
      return context.t.history.minutesAgo(n: diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return context.t.history.hoursAgo(n: diff.inHours);
    }
    return context.t.history.daysAgo(n: diff.inDays);
  }

  String _formatCoords() {
    final lat = record.latitude.toStringAsFixed(5);
    final lng = record.longitude.toStringAsFixed(5);
    return '$lat°, $lng°';
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _timeFormat.format(DateTime.parse(record.timestamp));
    final relStr = _relativeTime(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: .all(color: AppColors.border),
        borderRadius: .circular(15),
      ),
      child: Row(
        spacing: 12,
        children: [
          isLatest ? const _PulseDot() : const _StaticDot(active: false),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              spacing: 4,
              children: [
                Text(
                  _formatCoords(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: .w500,
                    fontFamily: 'monospace',
                    color: AppColors.textPrimary,
                  ),
                  overflow: .ellipsis,
                ),
                Row(
                  spacing: 6,
                  children: [
                    Text(
                      '$timeStr · $relStr',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    AccuracyBadge(
                      accuracy: GpsAccuracy.values
                          .byName(record.accuracy)
                          .toMeters,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            size: 14,
            color: AppColors.textDisabled,
          ),
        ],
      ),
    ),
    );
  }
}

class _StaticDot extends StatelessWidget {
  const _StaticDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.6)
            : AppColors.textDisabled,
        shape: .circle,
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    const curve = Cubic(0, 0, 0.2, 1);
    _scale = Tween<double>(
      begin: 1,
      end: 2.2,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));
    _opacity = Tween<double>(
      begin: 0.6,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: .center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, _) => Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: _opacity.value),
                  shape: .circle,
                ),
              ),
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: .circle,
            ),
          ),
        ],
      ),
    );
  }
}
