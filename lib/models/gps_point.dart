enum TrackingStatus {
  live,     // Real-time active GPS satellite feed
  demo,     // On-board GPS simulation engine
  stale,    // Weak satellite fix (>90s without ping)
  offline,  // Train parked or out of tracking zone
}

enum GpsValidationStatus {
  valid,
  speedViolation,
  geofenceDeviation,
  anomalousJump,
}

class GpsPoint {
  final double latitude;
  final double longitude;
  final double speedKmh;
  final double bearing;
  final double altitude;
  final DateTime timestamp;
  final GpsValidationStatus validationStatus;

  const GpsPoint({
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.bearing,
    this.altitude = 12.0,
    required this.timestamp,
    this.validationStatus = GpsValidationStatus.valid,
  });

  GpsPoint copyWith({
    double? latitude,
    double? longitude,
    double? speedKmh,
    double? bearing,
    double? altitude,
    DateTime? timestamp,
    GpsValidationStatus? validationStatus,
  }) {
    return GpsPoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speedKmh: speedKmh ?? this.speedKmh,
      bearing: bearing ?? this.bearing,
      altitude: altitude ?? this.altitude,
      timestamp: timestamp ?? this.timestamp,
      validationStatus: validationStatus ?? this.validationStatus,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'speedKmh': speedKmh,
    'bearing': bearing,
    'altitude': altitude,
    'timestamp': timestamp.toIso8601String(),
    'validationStatus': validationStatus.name,
  };
}
