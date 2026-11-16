class Station {
  final String id;
  final String code;
  final String nameEn;
  final String nameBn;
  final double latitude;
  final double longitude;
  final String division;
  final int platforms;
  final bool hasWifi;
  final bool hasWaitingRoom;

  const Station({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameBn,
    required this.latitude,
    required this.longitude,
    required this.division,
    this.platforms = 2,
    this.hasWifi = true,
    this.hasWaitingRoom = true,
  });

  String localizedName(String langCode) {
    return langCode == 'bn' ? nameBn : nameEn;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'nameEn': nameEn,
    'nameBn': nameBn,
    'latitude': latitude,
    'longitude': longitude,
    'division': division,
    'platforms': platforms,
  };

  factory Station.fromJson(Map<String, dynamic> json) => Station(
    id: json['id'] as String,
    code: json['code'] as String,
    nameEn: json['nameEn'] as String,
    nameBn: json['nameBn'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    division: json['division'] as String,
    platforms: json['platforms'] as int? ?? 2,
  );
}

class StationSchedule {
  final Station station;
  final String scheduledArrival;
  final String scheduledDeparture;
  final double distanceKmFromOrigin;
  final int platform;

  const StationSchedule({
    required this.station,
    required this.scheduledArrival,
    required this.scheduledDeparture,
    required this.distanceKmFromOrigin,
    this.platform = 1,
  });
}
