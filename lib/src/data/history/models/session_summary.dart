import 'package:geolocator/geolocator.dart';

import '../../../core/data/database/app_database.dart';
import '../../tracker/enums/gps_accuracy.dart';

class SessionSummary {
  SessionSummary({
    required this.session,
    required this.coordinates,
    required this.distanceKm,
  });

  final TrackingSession session;
  final List<TrackingCoordinate> coordinates;
  final double distanceKm;

  int get pointCount => coordinates.length;

  double get avgAccuracyMeters {
    if (coordinates.isEmpty) return 0;
    final total = coordinates
        .map((c) => GpsAccuracy.values.byName(c.accuracy).toMeters)
        .reduce((a, b) => a + b);
    return total / coordinates.length;
  }

  static double computeDistanceKm(List<TrackingCoordinate> coords) {
    if (coords.length < 2) return 0;
    var total = 0.0;
    for (var i = 1; i < coords.length; i++) {
      total += Geolocator.distanceBetween(
        coords[i - 1].latitude,
        coords[i - 1].longitude,
        coords[i].latitude,
        coords[i].longitude,
      );
    }
    return total / 1000;
  }
}
