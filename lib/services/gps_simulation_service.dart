import 'dart:math';
import '../models/gps_point.dart';
import '../models/route_segment.dart';
import '../models/station.dart';
import '../models/train.dart';

class GpsSimulationService {
  static const double earthRadiusKm = 6371.0;
  static const double maxPlausibleSpeedKmh = 125.0; // Max speed on Bangladesh broad/meter gauge
  static const double geofenceToleranceKm = 1.5;   // 1.5km buffer around railway corridor

  /// Haversine Formula for accurate spherical distance
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Calculates bearing in degrees (0 - 360)
  static double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);
    final dLonRad = _degreesToRadians(lon2 - lon1);

    final y = sin(dLonRad) * cos(lat2Rad);
    final x = cos(lat1Rad) * sin(lat2Rad) -
        sin(lat1Rad) * cos(lat2Rad) * cos(dLonRad);
    final radians = atan2(y, x);
    return (_radiansToDegrees(radians) + 360) % 360;
  }

  static double _degreesToRadians(double degrees) => degrees * pi / 180.0;
  static double _radiansToDegrees(double radians) => radians * 180.0 / pi;

  /// GPS validation engine
  static GpsValidationStatus validateGpsPoint(
    GpsPoint point,
    GpsPoint? previousPoint,
    RailwayRoute corridor,
  ) {
    // 1. Speed Violation check
    if (point.speedKmh > maxPlausibleSpeedKmh || point.speedKmh < 0) {
      return GpsValidationStatus.speedViolation;
    }

    // 2. Anomalous Jump check (teleportation detection)
    if (previousPoint != null) {
      final elapsedSeconds =
          point.timestamp.difference(previousPoint.timestamp).inSeconds.abs();
      if (elapsedSeconds > 0 && elapsedSeconds < 30) {
        final dist = calculateDistanceKm(
          previousPoint.latitude,
          previousPoint.longitude,
          point.latitude,
          point.longitude,
        );
        final impliedSpeed = (dist / (elapsedSeconds / 3600.0));
        if (impliedSpeed > 160.0) {
          return GpsValidationStatus.anomalousJump;
        }
      }
    }

    // 3. Geofence Track Corridor Deviation
    double minTrackDist = double.infinity;
    for (final coord in corridor.coordinates) {
      final d = calculateDistanceKm(
        point.latitude,
        point.longitude,
        coord.latitude,
        coord.longitude,
      );
      if (d < minTrackDist) {
        minTrackDist = d;
      }
    }
    if (minTrackDist > geofenceToleranceKm) {
      return GpsValidationStatus.geofenceDeviation;
    }

    return GpsValidationStatus.valid;
  }

  /// Calculates Estimated Arrival Time (ETA) formatted string
  static String calculateEta({
    required double distanceRemainingKm,
    required double currentSpeedKmh,
  }) {
    if (currentSpeedKmh <= 5.0) {
      return 'Delayed (Stationary)';
    }
    final hours = distanceRemainingKm / currentSpeedKmh;
    final arrivalTime = DateTime.now().add(Duration(minutes: (hours * 60).round()));
    final hour = arrivalTime.hour > 12
        ? arrivalTime.hour - 12
        : (arrivalTime.hour == 0 ? 12 : arrivalTime.hour);
    final minute = arrivalTime.minute.toString().padLeft(2, '0');
    final period = arrivalTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Simulates smooth movement along route polyline
  static Train stepTrainSimulation({
    required Train train,
    required RailwayRoute route,
    required double stepSpeedFactor,
  }) {
    final coords = route.coordinates;
    if (coords.length < 2) return train;

    // Find closest segment index
    int closestIndex = 0;
    double minDistance = double.infinity;
    for (int i = 0; i < coords.length; i++) {
      final d = calculateDistanceKm(
        train.currentPosition.latitude,
        train.currentPosition.longitude,
        coords[i].latitude,
        coords[i].longitude,
      );
      if (d < minDistance) {
        minDistance = d;
        closestIndex = i;
      }
    }

    int nextIndex = (closestIndex + 1) % coords.length;
    final targetPoint = coords[nextIndex];
    final currentLat = train.currentPosition.latitude;
    final currentLng = train.currentPosition.longitude;

    final segmentDist = calculateDistanceKm(
      currentLat,
      currentLng,
      targetPoint.latitude,
      targetPoint.longitude,
    );

    // If reached segment node, advance
    final stepDistance = 0.05 * stepSpeedFactor;
    double newLat;
    double newLng;

    if (segmentDist <= stepDistance) {
      newLat = targetPoint.latitude;
      newLng = targetPoint.longitude;
    } else {
      final fraction = min(1.0, stepDistance / segmentDist);
      newLat = currentLat + (targetPoint.latitude - currentLat) * fraction;
      newLng = currentLng + (targetPoint.longitude - currentLng) * fraction;
    }

    final bearing = calculateBearing(
      currentLat,
      currentLng,
      targetPoint.latitude,
      targetPoint.longitude,
    );

    // Fluctuating realistic railway cruising speed (65 - 88 km/h)
    final randomFluctuation = (sin(DateTime.now().millisecondsSinceEpoch / 2000.0) * 8.0);
    final speed = max(35.0, min(88.0, 75.0 + randomFluctuation));

    // Calculate nearest next station from train schedule
    Station nextStation = train.nextStation;
    double distToNext = double.infinity;
    for (final scheduleItem in train.schedule) {
      final d = calculateDistanceKm(
        newLat,
        newLng,
        scheduleItem.station.latitude,
        scheduleItem.station.longitude,
      );
      if (d < distToNext && d > 0.5) {
        distToNext = d;
        nextStation = scheduleItem.station;
      }
    }
    if (distToNext == double.infinity) {
      distToNext = 8.5;
    }

    final newGpsPoint = GpsPoint(
      latitude: newLat,
      longitude: newLng,
      speedKmh: speed,
      bearing: bearing,
      timestamp: DateTime.now(),
      validationStatus: GpsValidationStatus.valid,
    );

    final etaString = calculateEta(
      distanceRemainingKm: distToNext,
      currentSpeedKmh: speed,
    );

    // Journey progress
    final progress = min(99.0, max(5.0, (train.journeyProgressPercentage + (0.15 * stepSpeedFactor)) % 100.0));

    return train.copyWith(
      currentPosition: newGpsPoint,
      currentSpeedKmh: speed,
      nextStation: nextStation,
      distanceToNextStationKm: double.parse(distToNext.toStringAsFixed(1)),
      estimatedArrivalNextStation: etaString,
      journeyProgressPercentage: double.parse(progress.toStringAsFixed(1)),
    );
  }
}
