import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/components/theme/app_colors.dart';

class HomeMapSection extends StatelessWidget {
  const HomeMapSection({required this.height, this.position, super.key});

  final double height;
  final Position? position;

  static const _defaultCenter = LatLng(3.1569, 101.7123);

  @override
  Widget build(BuildContext context) {
    final center = position != null
        ? LatLng(position!.latitude, position!.longitude)
        : _defaultCenter;

    return ClipRRect(
      borderRadius: .circular(20),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.adoratech.adaro',
            ),
            if (position != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: center,
                    radius: 40,
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderColor: AppColors.primary.withValues(alpha: 0.3),
                    borderStrokeWidth: 1,
                    useRadiusInMeter: true,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 28,
                  height: 28,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
