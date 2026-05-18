import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';
import '../../../core/data/database/app_database.dart';
import '../../../data/tracker/enums/gps_accuracy.dart';
import '../widgets/detail/c_point_row.dart';

@RoutePage()
class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({required this.records, super.key});

  final List<TrackingCoordinate> records;

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
      final bounds = LatLngBounds.fromPoints(points);
      final hasArea =
          bounds.north != bounds.south || bounds.east != bounds.west;
      mapOptions = hasArea
          ? MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(64),
              ),
            )
          : MapOptions(initialCenter: points.first, initialZoom: 16);
    }

    return Scaffold(
      backgroundColor: AppColors.offWhiteBg,
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: .start,
        spacing: context.s,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  options: mapOptions,
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.adoratech.adora',
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
                        for (var i = 1; i < points.length - 1; i++)
                          _buildMarker(
                            points[i],
                            AppColors.textTertiary,
                            small: true,
                          ),
                        _buildMarker(points.first, AppColors.success),
                        if (points.length > 1)
                          _buildMarker(points.last, AppColors.primaryDark),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: context.m),
              itemCount: records.length,
              separatorBuilder: (_, _) => context.xxs.vSpace,
              itemBuilder: (_, index) {
                final rec = records[index];
                final prev = index > 0 ? records[index - 1] : null;
                final distM = prev != null
                    ? Geolocator.distanceBetween(
                        prev.latitude,
                        prev.longitude,
                        rec.latitude,
                        rec.longitude,
                      )
                    : null;
                final time = DateFormat(
                  'h:mm:ss a',
                ).format(DateTime.parse(rec.timestamp).toLocal());
                final accuracy = GpsAccuracy.values
                    .byName(rec.accuracy)
                    .toMeters;
                return CPointRow(
                  index: index,
                  time: time,
                  accuracy: accuracy,
                  distM: distM,
                  isFirst: index == 0,
                  isLast: index == records.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static Marker _buildMarker(LatLng point, Color color, {bool small = false}) {
    final size = small ? 10.0 : 20.0;
    return Marker(
      point: point,
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: .circle,
          border: .all(color: Colors.white, width: small ? 1.5 : 2.5),
          boxShadow: small
              ? null
              : [
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
