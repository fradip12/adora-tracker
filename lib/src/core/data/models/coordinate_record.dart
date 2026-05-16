class CoordinateRecord {
  const CoordinateRecord({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.id,
  });

  final int? id;
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  factory CoordinateRecord.fromMap(Map<String, dynamic> map) =>
      CoordinateRecord(
        id: map['id'] as int?,
        latitude: map['latitude'] as double,
        longitude: map['longitude'] as double,
        accuracy: map['accuracy'] as double,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          map['timestamp'] as int,
        ),
      );
}
