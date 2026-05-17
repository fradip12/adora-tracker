enum TrackingInterval {
  s10,
  s30,
  m1;

  String get label => switch (this) {
        .s10 => '10s',
        .s30 => '30s',
        .m1 => '1m',
      };

  Duration get duration => switch (this) {
        .s10 => const Duration(seconds: 10),
        .s30 => const Duration(seconds: 30),
        .m1 => const Duration(minutes: 1),
      };

  String get prefValue => name;

  static TrackingInterval fromPrefValue(String value) =>
      values.firstWhere((e) => e.name == value, orElse: () => .s30);
}
