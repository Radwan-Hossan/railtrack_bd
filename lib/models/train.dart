import 'station.dart';
import 'gps_point.dart';

enum TrainType {
  intercity,
  express,
  commuter,
}

class Train {
  final String id;
  final String trainNumber;
  final String nameEn;
  final String nameBn;
  final TrainType type;
  final Station origin;
  final Station destination;
  final String departureTime;
  final String arrivalTime;
  final List<StationSchedule> schedule;
  final double totalDistanceKm;
  final String offDay;
  final int totalCoaches;
  final List<String> coachClasses;

  // Real-time tracking fields
  final TrackingStatus trackingStatus;
  final GpsPoint currentPosition;
  final double currentSpeedKmh;
  final double delayMinutes;
  final Station nextStation;
  final double distanceToNextStationKm;
  final String estimatedArrivalNextStation;
  final double journeyProgressPercentage; // 0.0 to 100.0

  const Train({
    required this.id,
    required this.trainNumber,
    required this.nameEn,
    required this.nameBn,
    required this.type,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.schedule,
    required this.totalDistanceKm,
    this.offDay = 'None',
    this.totalCoaches = 16,
    this.coachClasses = const ['AC_B', 'SNIGDHA', 'SHOVAN_CHAIR'],
    this.trackingStatus = TrackingStatus.demo,
    required this.currentPosition,
    this.currentSpeedKmh = 72.0,
    this.delayMinutes = 0.0,
    required this.nextStation,
    this.distanceToNextStationKm = 14.5,
    this.estimatedArrivalNextStation = '11:45 AM',
    this.journeyProgressPercentage = 35.0,
  });

  String localizedName(String langCode) {
    return langCode == 'bn' ? nameBn : nameEn;
  }

  Train copyWith({
    TrackingStatus? trackingStatus,
    GpsPoint? currentPosition,
    double? currentSpeedKmh,
    double? delayMinutes,
    Station? nextStation,
    double? distanceToNextStationKm,
    String? estimatedArrivalNextStation,
    double? journeyProgressPercentage,
  }) {
    return Train(
      id: id,
      trainNumber: trainNumber,
      nameEn: nameEn,
      nameBn: nameBn,
      type: type,
      origin: origin,
      destination: destination,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      schedule: schedule,
      totalDistanceKm: totalDistanceKm,
      offDay: offDay,
      totalCoaches: totalCoaches,
      coachClasses: coachClasses,
      trackingStatus: trackingStatus ?? this.trackingStatus,
      currentPosition: currentPosition ?? this.currentPosition,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      delayMinutes: delayMinutes ?? this.delayMinutes,
      nextStation: nextStation ?? this.nextStation,
      distanceToNextStationKm: distanceToNextStationKm ?? this.distanceToNextStationKm,
      estimatedArrivalNextStation: estimatedArrivalNextStation ?? this.estimatedArrivalNextStation,
      journeyProgressPercentage: journeyProgressPercentage ?? this.journeyProgressPercentage,
    );
  }
}
