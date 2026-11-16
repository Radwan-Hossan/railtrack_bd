import '../models/station.dart';
import '../models/train.dart';
import '../models/gps_point.dart';
import '../models/route_segment.dart';

class BangladeshRailwayData {
  // --- Stations Database ---
  static const Station kamalapur = Station(
    id: 'DHK',
    code: 'DA',
    nameEn: 'Dhaka Kamalapur',
    nameBn: 'ঢাকা কমলাপুর',
    latitude: 23.7314,
    longitude: 90.4267,
    division: 'Dhaka',
    platforms: 8,
  );

  static const Station airport = Station(
    id: 'AIR',
    code: 'BBA',
    nameEn: 'Dhaka Airport',
    nameBn: 'বিমানবন্দর',
    latitude: 23.8517,
    longitude: 90.4078,
    division: 'Dhaka',
    platforms: 3,
  );

  static const Station joydebpur = Station(
    id: 'JOY',
    code: 'JDB',
    nameEn: 'Joydebpur Junction',
    nameBn: 'জয়দেবপুর জংশন',
    latitude: 23.9999,
    longitude: 90.4203,
    division: 'Dhaka',
    platforms: 4,
  );

  static const Station tongi = Station(
    id: 'TNG',
    code: 'TGI',
    nameEn: 'Tongi Junction',
    nameBn: 'টঙ্গী জংশন',
    latitude: 23.8961,
    longitude: 90.4025,
    division: 'Dhaka',
    platforms: 3,
  );

  static const Station bhairabBazar = Station(
    id: 'BHR',
    code: 'BBZ',
    nameEn: 'Bhairab Bazar Junction',
    nameBn: 'ভৈরব বাজার জংশন',
    latitude: 24.0489,
    longitude: 90.9856,
    division: 'Dhaka',
    platforms: 4,
  );

  static const Station brahmanbaria = Station(
    id: 'BRB',
    code: 'BBA',
    nameEn: 'Brahmanbaria',
    nameBn: 'ব্রাহ্মণবাড়িয়া',
    latitude: 23.9608,
    longitude: 91.1115,
    division: 'Chittagong',
    platforms: 3,
  );

  static const Station akhaura = Station(
    id: 'AKH',
    code: 'AKH',
    nameEn: 'Akhaura Junction',
    nameBn: 'আখাউড়া জংশন',
    latitude: 23.8710,
    longitude: 91.2144,
    division: 'Chittagong',
    platforms: 4,
  );

  static const Station feni = Station(
    id: 'FEN',
    code: 'FNI',
    nameEn: 'Feni Junction',
    nameBn: 'ফেনী জংশন',
    latitude: 23.0159,
    longitude: 91.3976,
    division: 'Chittagong',
    platforms: 3,
  );

  static const Station chittagong = Station(
    id: 'CTG',
    code: 'CG',
    nameEn: 'Chittagong',
    nameBn: 'চট্টগ্রাম',
    latitude: 22.3355,
    longitude: 91.8315,
    division: 'Chittagong',
    platforms: 6,
  );

  static const Station sylhet = Station(
    id: 'SYL',
    code: 'SLT',
    nameEn: 'Sylhet',
    nameBn: 'সিলেট',
    latitude: 24.8829,
    longitude: 91.8714,
    division: 'Sylhet',
    platforms: 4,
  );

  static const Station srimangal = Station(
    id: 'SRI',
    code: 'SRM',
    nameEn: 'Srimangal',
    nameBn: 'শ্রীমঙ্গল',
    latitude: 24.3065,
    longitude: 91.7296,
    division: 'Sylhet',
    platforms: 2,
  );

  static const Station rajshahi = Station(
    id: 'RAJ',
    code: 'RSH',
    nameEn: 'Rajshahi',
    nameBn: 'রাজশাহী',
    latitude: 24.3745,
    longitude: 88.6042,
    division: 'Rajshahi',
    platforms: 4,
  );

  static const Station ishwardi = Station(
    id: 'ISD',
    code: 'ISD',
    nameEn: 'Ishwardi Junction',
    nameBn: 'ঈশ্বরদী জংশন',
    latitude: 24.1297,
    longitude: 89.0664,
    division: 'Rajshahi',
    platforms: 5,
  );

  static List<Station> get allStations => [
    kamalapur,
    airport,
    tongi,
    joydebpur,
    bhairabBazar,
    brahmanbaria,
    akhaura,
    feni,
    chittagong,
    sylhet,
    srimangal,
    ishwardi,
    rajshahi,
  ];

  // --- Railway Route Track Geometries (PostGIS Polyline simulation) ---
  static const RailwayRoute dhakaChittagongRoute = RailwayRoute(
    id: 'ROUTE_DHK_CTG',
    routeName: 'Dhaka - Chittagong Main Line',
    totalDistanceKm: 320.0,
    coordinates: [
      LatLngPoint(23.7314, 90.4267), // Kamalapur
      LatLngPoint(23.7745, 90.4180),
      LatLngPoint(23.8517, 90.4078), // Airport
      LatLngPoint(23.8961, 90.4025), // Tongi
      LatLngPoint(23.9520, 90.6200),
      LatLngPoint(24.0489, 90.9856), // Bhairab Bazar
      LatLngPoint(23.9608, 91.1115), // Brahmanbaria
      LatLngPoint(23.8710, 91.2144), // Akhaura
      LatLngPoint(23.4607, 91.1809), // Comilla
      LatLngPoint(23.0159, 91.3976), // Feni
      LatLngPoint(22.6850, 91.6500),
      LatLngPoint(22.3355, 91.8315), // Chittagong
    ],
  );

  static const RailwayRoute dhakaSylhetRoute = RailwayRoute(
    id: 'ROUTE_DHK_SYL',
    routeName: 'Dhaka - Sylhet Line',
    totalDistanceKm: 319.0,
    coordinates: [
      LatLngPoint(23.7314, 90.4267), // Kamalapur
      LatLngPoint(23.8517, 90.4078), // Airport
      LatLngPoint(23.8961, 90.4025), // Tongi
      LatLngPoint(24.0489, 90.9856), // Bhairab
      LatLngPoint(23.8710, 91.2144), // Akhaura
      LatLngPoint(24.1700, 91.4300), // Shaistaganj
      LatLngPoint(24.3065, 91.7296), // Srimangal
      LatLngPoint(24.4800, 91.7700), // Kulaura
      LatLngPoint(24.8829, 91.8714), // Sylhet
    ],
  );

  static const RailwayRoute dhakaRajshahiRoute = RailwayRoute(
    id: 'ROUTE_DHK_RAJ',
    routeName: 'Dhaka - Rajshahi Western Corridor',
    totalDistanceKm: 343.0,
    coordinates: [
      LatLngPoint(23.7314, 90.4267), // Kamalapur
      LatLngPoint(23.8517, 90.4078), // Airport
      LatLngPoint(23.9999, 90.4203), // Joydebpur
      LatLngPoint(24.0600, 90.1500), // Bangabandhu Bridge East
      LatLngPoint(24.3900, 89.7500), // Bangabandhu Bridge West
      LatLngPoint(24.1297, 89.0664), // Ishwardi
      LatLngPoint(24.3745, 88.6042), // Rajshahi
    ],
  );

  // --- Train Database ---
  static List<Train> get initialTrains => [
    Train(
      id: 'TR_701',
      trainNumber: '701',
      nameEn: 'Suborno Express',
      nameBn: 'সুবর্ণ এক্সপ্রেস',
      type: TrainType.intercity,
      origin: chittagong,
      destination: kamalapur,
      departureTime: '07:00 AM',
      arrivalTime: '12:20 PM',
      totalDistanceKm: 320.0,
      offDay: 'Monday',
      totalCoaches: 18,
      coachClasses: const ['AC_B', 'SNIGDHA', 'SHOVAN_CHAIR'],
      trackingStatus: TrackingStatus.live,
      currentPosition: GpsPoint(
        latitude: 23.0159,
        longitude: 91.3976,
        speedKmh: 82.5,
        bearing: 315.0,
        timestamp: DateTime.now(),
      ),
      currentSpeedKmh: 82.5,
      delayMinutes: 0.0,
      nextStation: feni,
      distanceToNextStationKm: 8.2,
      estimatedArrivalNextStation: '09:42 AM',
      journeyProgressPercentage: 62.0,
      schedule: const [
        StationSchedule(station: chittagong, scheduledArrival: '07:00 AM', scheduledDeparture: '07:00 AM', distanceKmFromOrigin: 0),
        StationSchedule(station: feni, scheduledArrival: '08:35 AM', scheduledDeparture: '08:40 AM', distanceKmFromOrigin: 95),
        StationSchedule(station: airport, scheduledArrival: '11:55 AM', scheduledDeparture: '12:00 PM', distanceKmFromOrigin: 305),
        StationSchedule(station: kamalapur, scheduledArrival: '12:20 PM', scheduledDeparture: '12:20 PM', distanceKmFromOrigin: 320),
      ],
    ),
    Train(
      id: 'TR_787',
      trainNumber: '787',
      nameEn: 'Sonar Bangla Express',
      nameBn: 'সোনার বাংলা এক্সপ্রেস',
      type: TrainType.intercity,
      origin: kamalapur,
      destination: chittagong,
      departureTime: '07:00 AM',
      arrivalTime: '12:15 PM',
      totalDistanceKm: 320.0,
      offDay: 'Wednesday',
      totalCoaches: 16,
      coachClasses: const ['AC_B', 'SNIGDHA', 'SHOVAN_CHAIR'],
      trackingStatus: TrackingStatus.live,
      currentPosition: GpsPoint(
        latitude: 23.9608,
        longitude: 91.1115,
        speedKmh: 78.0,
        bearing: 135.0,
        timestamp: DateTime.now(),
      ),
      currentSpeedKmh: 78.0,
      delayMinutes: 8.0,
      nextStation: brahmanbaria,
      distanceToNextStationKm: 12.4,
      estimatedArrivalNextStation: '09:18 AM',
      journeyProgressPercentage: 45.0,
      schedule: const [
        StationSchedule(station: kamalapur, scheduledArrival: '07:00 AM', scheduledDeparture: '07:00 AM', distanceKmFromOrigin: 0),
        StationSchedule(station: airport, scheduledArrival: '07:23 AM', scheduledDeparture: '07:28 AM', distanceKmFromOrigin: 15),
        StationSchedule(station: brahmanbaria, scheduledArrival: '09:10 AM', scheduledDeparture: '09:14 AM', distanceKmFromOrigin: 125),
        StationSchedule(station: chittagong, scheduledArrival: '12:15 PM', scheduledDeparture: '12:15 PM', distanceKmFromOrigin: 320),
      ],
    ),
    Train(
      id: 'TR_709',
      trainNumber: '709',
      nameEn: 'Parabat Express',
      nameBn: 'পারাবত এক্সপ্রেস',
      type: TrainType.intercity,
      origin: kamalapur,
      destination: sylhet,
      departureTime: '06:20 AM',
      arrivalTime: '01:00 PM',
      totalDistanceKm: 319.0,
      offDay: 'Tuesday',
      totalCoaches: 16,
      coachClasses: const ['AC_B', 'SNIGDHA', 'SHOVAN_CHAIR'],
      trackingStatus: TrackingStatus.demo,
      currentPosition: GpsPoint(
        latitude: 24.3065,
        longitude: 91.7296,
        speedKmh: 68.0,
        bearing: 45.0,
        timestamp: DateTime.now(),
      ),
      currentSpeedKmh: 68.0,
      delayMinutes: 15.0,
      nextStation: srimangal,
      distanceToNextStationKm: 6.8,
      estimatedArrivalNextStation: '11:12 AM',
      journeyProgressPercentage: 70.0,
      schedule: const [
        StationSchedule(station: kamalapur, scheduledArrival: '06:20 AM', scheduledDeparture: '06:20 AM', distanceKmFromOrigin: 0),
        StationSchedule(station: airport, scheduledArrival: '06:45 AM', scheduledDeparture: '06:50 AM', distanceKmFromOrigin: 15),
        StationSchedule(station: bhairabBazar, scheduledArrival: '08:20 AM', scheduledDeparture: '08:25 AM', distanceKmFromOrigin: 84),
        StationSchedule(station: srimangal, scheduledArrival: '10:55 AM', scheduledDeparture: '11:00 AM', distanceKmFromOrigin: 220),
        StationSchedule(station: sylhet, scheduledArrival: '01:00 PM', scheduledDeparture: '01:00 PM', distanceKmFromOrigin: 319),
      ],
    ),
    Train(
      id: 'TR_759',
      trainNumber: '759',
      nameEn: 'Padma Express',
      nameBn: 'পদ্মা এক্সপ্রেস',
      type: TrainType.intercity,
      origin: kamalapur,
      destination: rajshahi,
      departureTime: '11:00 PM',
      arrivalTime: '04:30 AM',
      totalDistanceKm: 343.0,
      offDay: 'Tuesday',
      totalCoaches: 14,
      coachClasses: const ['AC_B', 'SNIGDHA', 'SHOVAN_CHAIR'],
      trackingStatus: TrackingStatus.stale,
      currentPosition: GpsPoint(
        latitude: 24.1297,
        longitude: 89.0664,
        speedKmh: 45.0,
        bearing: 290.0,
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      currentSpeedKmh: 45.0,
      delayMinutes: 22.0,
      nextStation: ishwardi,
      distanceToNextStationKm: 18.0,
      estimatedArrivalNextStation: '03:15 AM',
      journeyProgressPercentage: 78.0,
      schedule: const [
        StationSchedule(station: kamalapur, scheduledArrival: '11:00 PM', scheduledDeparture: '11:00 PM', distanceKmFromOrigin: 0),
        StationSchedule(station: joydebpur, scheduledArrival: '11:50 PM', scheduledDeparture: '11:55 PM', distanceKmFromOrigin: 35),
        StationSchedule(station: ishwardi, scheduledArrival: '02:50 AM', scheduledDeparture: '03:00 AM', distanceKmFromOrigin: 250),
        StationSchedule(station: rajshahi, scheduledArrival: '04:30 AM', scheduledDeparture: '04:30 AM', distanceKmFromOrigin: 343),
      ],
    ),
    Train(
      id: 'TR_703',
      trainNumber: '703',
      nameEn: 'Mohanagar Provati',
      nameBn: 'মহানগর প্রভাতী',
      type: TrainType.intercity,
      origin: kamalapur,
      destination: chittagong,
      departureTime: '07:45 AM',
      arrivalTime: '02:00 PM',
      totalDistanceKm: 320.0,
      offDay: 'None',
      totalCoaches: 16,
      coachClasses: const ['AC_B', 'SNIGDHA', 'SHOVAN_CHAIR'],
      trackingStatus: TrackingStatus.offline,
      currentPosition: GpsPoint(
        latitude: 23.7314,
        longitude: 90.4267,
        speedKmh: 0.0,
        bearing: 0.0,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      currentSpeedKmh: 0.0,
      delayMinutes: 0.0,
      nextStation: airport,
      distanceToNextStationKm: 15.0,
      estimatedArrivalNextStation: '08:12 AM',
      journeyProgressPercentage: 0.0,
      schedule: const [
        StationSchedule(station: kamalapur, scheduledArrival: '07:45 AM', scheduledDeparture: '07:45 AM', distanceKmFromOrigin: 0),
        StationSchedule(station: airport, scheduledArrival: '08:12 AM', scheduledDeparture: '08:17 AM', distanceKmFromOrigin: 15),
        StationSchedule(station: bhairabBazar, scheduledArrival: '09:40 AM', scheduledDeparture: '09:45 AM', distanceKmFromOrigin: 84),
        StationSchedule(station: chittagong, scheduledArrival: '02:00 PM', scheduledDeparture: '02:00 PM', distanceKmFromOrigin: 320),
      ],
    ),
    Train(
      id: 'TR_10',
      trainNumber: '10',
      nameEn: 'Surma Mail',
      nameBn: 'সুরমা মেইল',
      type: TrainType.express,
      origin: sylhet,
      destination: kamalapur,
      departureTime: '09:30 PM',
      arrivalTime: '08:10 AM',
      totalDistanceKm: 319.0,
      offDay: 'None',
      totalCoaches: 12,
      coachClasses: const ['SHOVAN', 'SHULOV'],
      trackingStatus: TrackingStatus.live,
      currentPosition: GpsPoint(
        latitude: 24.0489,
        longitude: 90.9856,
        speedKmh: 54.0,
        bearing: 220.0,
        timestamp: DateTime.now(),
      ),
      currentSpeedKmh: 54.0,
      delayMinutes: 30.0,
      nextStation: bhairabBazar,
      distanceToNextStationKm: 11.2,
      estimatedArrivalNextStation: '05:30 AM',
      journeyProgressPercentage: 68.0,
      schedule: const [
        StationSchedule(station: sylhet, scheduledArrival: '09:30 PM', scheduledDeparture: '09:30 PM', distanceKmFromOrigin: 0),
        StationSchedule(station: srimangal, scheduledArrival: '12:15 AM', scheduledDeparture: '12:25 AM', distanceKmFromOrigin: 99),
        StationSchedule(station: akhaura, scheduledArrival: '03:40 AM', scheduledDeparture: '03:55 AM', distanceKmFromOrigin: 195),
        StationSchedule(station: bhairabBazar, scheduledArrival: '05:20 AM', scheduledDeparture: '05:35 AM', distanceKmFromOrigin: 235),
        StationSchedule(station: airport, scheduledArrival: '07:30 AM', scheduledDeparture: '07:38 AM', distanceKmFromOrigin: 304),
        StationSchedule(station: kamalapur, scheduledArrival: '08:10 AM', scheduledDeparture: '08:10 AM', distanceKmFromOrigin: 319),
      ],
    ),
    Train(
      id: 'TR_COMM_TURAG',
      trainNumber: 'COMM-1',
      nameEn: 'Turag Commuter',
      nameBn: 'তুরাগ কমিউটার',
      type: TrainType.commuter,
      origin: kamalapur,
      destination: joydebpur,
      departureTime: '05:00 PM',
      arrivalTime: '06:15 PM',
      totalDistanceKm: 35.0,
      offDay: 'Friday',
      totalCoaches: 10,
      coachClasses: const ['SHOVAN', 'COMMUTER'],
      trackingStatus: TrackingStatus.live,
      currentPosition: GpsPoint(
        latitude: 23.8961,
        longitude: 90.4025,
        speedKmh: 42.0,
        bearing: 5.0,
        timestamp: DateTime.now(),
      ),
      currentSpeedKmh: 42.0,
      delayMinutes: 4.0,
      nextStation: joydebpur,
      distanceToNextStationKm: 14.0,
      estimatedArrivalNextStation: '06:10 PM',
      journeyProgressPercentage: 60.0,
      schedule: const [
        StationSchedule(station: kamalapur, scheduledArrival: '05:00 PM', scheduledDeparture: '05:00 PM', distanceKmFromOrigin: 0),
        StationSchedule(station: airport, scheduledArrival: '05:25 PM', scheduledDeparture: '05:30 PM', distanceKmFromOrigin: 15),
        StationSchedule(station: tongi, scheduledArrival: '05:42 PM', scheduledDeparture: '05:46 PM', distanceKmFromOrigin: 21),
        StationSchedule(station: joydebpur, scheduledArrival: '06:15 PM', scheduledDeparture: '06:15 PM', distanceKmFromOrigin: 35),
      ],
    ),
    Train(
      id: 'TR_COMM_TITAS',
      trainNumber: 'COMM-33',
      nameEn: 'Titas Commuter',
      nameBn: 'তিতাস কমিউটার',
      type: TrainType.commuter,
      origin: kamalapur,
      destination: brahmanbaria,
      departureTime: '09:45 AM',
      arrivalTime: '12:30 PM',
      totalDistanceKm: 125.0,
      offDay: 'None',
      totalCoaches: 12,
      coachClasses: const ['SHOVAN', 'COMMUTER'],
      trackingStatus: TrackingStatus.demo,
      currentPosition: GpsPoint(
        latitude: 23.8961,
        longitude: 90.4025,
        speedKmh: 58.0,
        bearing: 40.0,
        timestamp: DateTime.now(),
      ),
      currentSpeedKmh: 58.0,
      delayMinutes: 0.0,
      nextStation: bhairabBazar,
      distanceToNextStationKm: 28.0,
      estimatedArrivalNextStation: '11:15 AM',
      journeyProgressPercentage: 42.0,
      schedule: const [
        StationSchedule(station: kamalapur, scheduledArrival: '09:45 AM', scheduledDeparture: '09:45 AM', distanceKmFromOrigin: 0),
        StationSchedule(station: airport, scheduledArrival: '10:08 AM', scheduledDeparture: '10:13 AM', distanceKmFromOrigin: 15),
        StationSchedule(station: tongi, scheduledArrival: '10:25 AM', scheduledDeparture: '10:28 AM', distanceKmFromOrigin: 21),
        StationSchedule(station: bhairabBazar, scheduledArrival: '11:35 AM', scheduledDeparture: '11:42 AM', distanceKmFromOrigin: 84),
        StationSchedule(station: brahmanbaria, scheduledArrival: '12:30 PM', scheduledDeparture: '12:30 PM', distanceKmFromOrigin: 125),
      ],
    ),
  ];
}
