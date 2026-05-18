import 'package:geolocator/geolocator.dart';

enum GpsAccuracy {
  best,
  high,
  medium,
  low,
  lowest;

  static GpsAccuracy fromMeters(double meters) {
    if (meters <= 5) return .best;
    if (meters <= 10) return .high;
    if (meters <= 25) return .medium;
    if (meters <= 50) return .low;
    return .lowest;
  }

  double get toMeters => switch (this) {
    .best => 5.0,
    .high => 10.0,
    .medium => 25.0,
    .low => 50.0,
    .lowest => 100.0,
  };

  LocationAccuracy get toLocationAccuracy => switch (this) {
    .best => LocationAccuracy.best,
    .high => LocationAccuracy.high,
    .medium => LocationAccuracy.medium,
    .low => LocationAccuracy.low,
    .lowest => LocationAccuracy.lowest,
  };
}
