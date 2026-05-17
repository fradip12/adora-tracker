import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/data/models/coordinate_record.dart';

@RoutePage()
class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({required this.records, super.key});

  final List<CoordinateRecord> records;

  @override
  Widget build(BuildContext context) {
    final points = records.map((r) => LatLng(r.latitude, r.longitude)).toList();

    if (points.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.offWhiteBg,
        body: Center(
          child: Text(
            context.t.history.empty,
            style: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
          ),
        ),
      );
    }

    final MapOptions mapOptions;
    if (points.length == 1) {
      mapOptions = MapOptions(initialCenter: points.first, initialZoom: 16);
    } else {
      mapOptions = MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(64),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: mapOptions,
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.adoratech.adaro',
              ),
              if (points.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: points,
                      strokeWidth: 4,
                      color: AppColors.primaryDark,
                      borderStrokeWidth: 1.5,
                      borderColor: Colors.white.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  _buildMarker(points.first, AppColors.success),
                  if (points.length > 1)
                    _buildMarker(points.last, AppColors.primaryDark),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _BackButton(onTap: () => context.maybePop()),
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(LatLng point, Color color) {
    return Marker(
      point: point,
      width: 20,
      height: 20,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: .circle,
          border: .all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          shape: .circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          LucideIcons.arrowLeft,
          size: 18,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
