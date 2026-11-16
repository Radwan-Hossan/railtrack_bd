import '../models/train.dart';
import '../models/station.dart';
import '../data/bangladesh_railway_data.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'https://api.railtrack.bd/v1'});

  Future<List<Train>> fetchActiveTrains() async {
    // Simulated REST API call with instant local fallback
    await Future.delayed(const Duration(milliseconds: 300));
    return BangladeshRailwayData.initialTrains;
  }

  Future<List<Station>> fetchAllStations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return BangladeshRailwayData.allStations;
  }

  Future<Map<String, dynamic>> fetchAdminTelemetry() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'activeTrackers': 48,
      'postgisQueriesPerSec': 142.5,
      'redisCacheHitRatio': 99.4,
      'geofenceViolations24h': 1,
      'serverUptime': '99.98%',
      'lastSync': DateTime.now().toIso8601String(),
    };
  }
}
