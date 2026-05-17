enum AccuracyLevel {
  good,
  ok,
  warn;

  static AccuracyLevel fromMeters(double meters) {
    if (meters <= 6) return .good;
    if (meters <= 15) return .ok;
    return .warn;
  }
}
