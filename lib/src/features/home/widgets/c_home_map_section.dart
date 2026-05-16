import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/components/theme/app_colors.dart';

class HomeMapSection extends StatefulWidget {
  const HomeMapSection({
    required this.height,
    this.position,
    this.trackPoints = const [],
    super.key,
  });

  final double height;
  final Position? position;
  final List<LatLng> trackPoints;

  @override
  State<HomeMapSection> createState() => _HomeMapSectionState();
}

class _HomeMapSectionState extends State<HomeMapSection> {
  late final MapController _mapController;

  static const _defaultCenter = LatLng(3.1569, 101.7123);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(HomeMapSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pos = widget.position;
    if (pos != null && pos != oldWidget.position) {
      _mapController.move(
        LatLng(pos.latitude, pos.longitude),
        _mapController.camera.zoom,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.position != null
        ? LatLng(widget.position!.latitude, widget.position!.longitude)
        : _defaultCenter;

    return ClipRRect(
      borderRadius: .circular(20),
      child: SizedBox(
        height: widget.height,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 16,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.adoratech.adaro',
            ),
            if (widget.trackPoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.trackPoints,
                    strokeWidth: 4,
                    color: AppColors.primaryDark,
                    borderStrokeWidth: 1.5,
                    borderColor: Colors.white.withValues(alpha: 0.6),
                  ),
                ],
              ),
            if (widget.position != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 40,
                    height: 40,
                    child: const _PulsingMarker(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PulsingMarker extends StatefulWidget {
  const _PulsingMarker();

  @override
  State<_PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<_PulsingMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _scale = Tween<double>(begin: 0.4, end: 1.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 0.65, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          alignment: .center,
          children: [
            Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: .circle,
                  color: AppColors.primaryDark.withValues(alpha: _opacity.value),
                ),
              ),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: .circle,
                color: AppColors.primaryDark,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
