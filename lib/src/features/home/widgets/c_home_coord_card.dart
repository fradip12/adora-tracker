import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';
import 'c_home_coord_item.dart';

class HomeCoordCard extends StatelessWidget {
  const HomeCoordCard({this.position, super.key});

  final ({double lat, double lng, double accuracy})? position;

  @override
  Widget build(BuildContext context) {
    final lat = position?.lat;
    final lon = position?.lng;

    return Container(
      padding: .all(context.m),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: .all(color: AppColors.border),
        borderRadius: .circular(18),
      ),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisAlignment: .center,
        spacing: context.xs,
        children: [
          Text(
            context.t.home.currentPosition,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.08 * 11,
              color: AppColors.textTertiary,
            ),
          ),

          IntrinsicHeight(
            child: Row(
              spacing: context.s,
              children: [
                Expanded(
                  child: HomeCoordItem(
                    label: context.t.home.labelLatitude,
                    value: lat != null ? lat.toStringAsFixed(4) : '--',
                    suffix: lat != null ? (lat >= 0 ? '°N' : '°S') : '',
                  ),
                ),
                const VerticalDivider(
                  width: 33,
                  thickness: 1,
                  color: AppColors.borderLight,
                ),
                Expanded(
                  child: HomeCoordItem(
                    label: context.t.home.labelLongitude,
                    value: lon != null ? lon.abs().toStringAsFixed(4) : '--',
                    suffix: lon != null ? (lon >= 0 ? '°E' : '°W') : '',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
