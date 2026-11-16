import 'dart:async';
import 'package:flutter/material.dart';
import '../models/train.dart';
import '../models/gps_point.dart';
import '../models/route_segment.dart';
import '../models/alert.dart';
import '../data/bangladesh_railway_data.dart';
import '../services/gps_simulation_service.dart';
import '../services/websocket_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class TrainTrackingProvider extends ChangeNotifier {
  List<Train> _trains = [];
  Train? _selectedTrain;
  List<String> _favoriteTrainIds = [];
  List<TrainAlert> _alerts = [];
  String _searchQuery = '';
  String _selectedStatusFilter = 'all'; // all, running, delayed, on_time, favorites
  String _selectedTrainTypeFilter = 'all'; // all, intercity, express, commuter
  String _sortBy = 'name'; // name, departure, delay, progress
  bool _sortAscending = true;
  
  // GPS Simulation engine variables
  Timer? _simulationTimer;
  bool _isSimulating = true;
  double _simSpeedFactor = 1.0; // 1x, 2x, 5x
  
  // WebSocket client
  final WebSocketService _webSocketService = WebSocketService();

  TrainTrackingProvider() {
    _init();
  }

  List<Train> get trains => _trains;
  Train? get selectedTrain => _selectedTrain;
  List<String> get favoriteTrainIds => _favoriteTrainIds;
  List<TrainAlert> get alerts => _alerts;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedStatusFilter; // Backward compatibility
  String get selectedStatusFilter => _selectedStatusFilter;
  String get selectedTrainTypeFilter => _selectedTrainTypeFilter;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  bool get hasActiveFilters =>
      _searchQuery.trim().isNotEmpty ||
      _selectedStatusFilter != 'all' ||
      _selectedTrainTypeFilter != 'all';
  bool get isSimulating => _isSimulating;
  double get simSpeedFactor => _simSpeedFactor;
  WebSocketConnectionState get wsState => _webSocketService.connectionState;

  Future<void> _init() async {
    _trains = List.from(BangladeshRailwayData.initialTrains);
    if (_trains.isNotEmpty) {
      _selectedTrain = _trains.first;
    }
    _favoriteTrainIds = await StorageService.getFavoriteTrainIds();
    _alerts = await StorageService.getSavedAlerts();
    _webSocketService.connect();
    _startGpsSimulation();
    notifyListeners();
  }

  void selectTrain(Train train) {
    _selectedTrain = train;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedStatusFilter = filter;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _selectedStatusFilter = filter;
    notifyListeners();
  }

  void setTrainTypeFilter(String typeFilter) {
    _selectedTrainTypeFilter = typeFilter;
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    if (_sortBy == sortBy) {
      _sortAscending = !_sortAscending;
    } else {
      _sortBy = sortBy;
      _sortAscending = true;
    }
    notifyListeners();
  }

  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedStatusFilter = 'all';
    _selectedTrainTypeFilter = 'all';
    _sortBy = 'name';
    _sortAscending = true;
    notifyListeners();
  }

  /// Parses 12-hour formatted time (e.g. "07:30 AM", "11:15 PM") to minutes from midnight
  int _parseTimeToMinutes(String timeStr) {
    try {
      final trimmed = timeStr.trim();
      final parts = trimmed.split(' ');
      if (parts.length < 2) return 0;
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);
      final isPm = parts[1].toUpperCase() == 'PM';
      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      return hour * 60 + minute;
    } catch (_) {
      return 0;
    }
  }

  List<Train> get filteredTrains {
    final rawQuery = _searchQuery.trim();
    final q = rawQuery.toLowerCase();

    final result = _trains.where((train) {
      // 1. Search Query: Matches train name (En/Bn), number, origin/destination (En/Bn/Code), and intermediate stops
      if (rawQuery.isNotEmpty) {
        final matchesTrainName = train.nameEn.toLowerCase().contains(q) ||
            train.nameBn.contains(rawQuery) ||
            train.trainNumber.toLowerCase().contains(q);

        final matchesOrigin = train.origin.nameEn.toLowerCase().contains(q) ||
            train.origin.nameBn.contains(rawQuery) ||
            train.origin.code.toLowerCase().contains(q);

        final matchesDest = train.destination.nameEn.toLowerCase().contains(q) ||
            train.destination.nameBn.contains(rawQuery) ||
            train.destination.code.toLowerCase().contains(q);

        final matchesSchedule = train.schedule.any((s) =>
            s.station.nameEn.toLowerCase().contains(q) ||
            s.station.nameBn.contains(rawQuery) ||
            s.station.code.toLowerCase().contains(q));

        if (!matchesTrainName && !matchesOrigin && !matchesDest && !matchesSchedule) {
          return false;
        }
      }

      // 2. Train Type Filter: All, Intercity, Mail/Express, Commuter
      switch (_selectedTrainTypeFilter) {
        case 'intercity':
          if (train.type != TrainType.intercity) return false;
          break;
        case 'express':
          if (train.type != TrainType.express) return false;
          break;
        case 'commuter':
          if (train.type != TrainType.commuter) return false;
          break;
        default:
          break;
      }

      // 3. Status Filter: All, Running, Delayed, On-Time, Favorites
      switch (_selectedStatusFilter) {
        case 'running':
          return train.trackingStatus == TrackingStatus.live ||
              train.trackingStatus == TrackingStatus.demo;
        case 'delayed':
          return train.delayMinutes > 5.0;
        case 'on_time':
          return train.delayMinutes <= 5.0;
        case 'favorites':
          return _favoriteTrainIds.contains(train.id);
        default:
          return true;
      }
    }).toList();

    // 4. Sorting: Name, Departure Time, Delay, Journey Progress
    result.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'departure':
          final aMin = _parseTimeToMinutes(a.departureTime);
          final bMin = _parseTimeToMinutes(b.departureTime);
          comparison = aMin.compareTo(bMin);
          break;
        case 'delay':
          comparison = a.delayMinutes.compareTo(b.delayMinutes);
          break;
        case 'progress':
          comparison = a.journeyProgressPercentage.compareTo(b.journeyProgressPercentage);
          break;
        case 'name':
        default:
          comparison = a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return result;
  }

  List<Train> get favoriteTrains {
    return _trains.where((t) => _favoriteTrainIds.contains(t.id)).toList();
  }

  bool isFavorite(String trainId) => _favoriteTrainIds.contains(trainId);

  Future<void> toggleFavorite(String trainId) async {
    if (_favoriteTrainIds.contains(trainId)) {
      _favoriteTrainIds.remove(trainId);
    } else {
      _favoriteTrainIds.add(trainId);
    }
    await StorageService.saveFavoriteTrainIds(_favoriteTrainIds);
    notifyListeners();
  }

  // --- Feature 1: Smart Destination Alarm Management ---
  Future<void> addAlert(TrainAlert alert) async {
    _alerts.add(alert);
    await StorageService.saveAlerts(_alerts);
    notifyListeners();
  }

  Future<void> deleteAlert(String alertId) async {
    _alerts.removeWhere((a) => a.id == alertId);
    await StorageService.saveAlerts(_alerts);
    notifyListeners();
  }

  Future<void> toggleAlertActive(String alertId, bool isActive) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isActive: isActive);
      await StorageService.saveAlerts(_alerts);
      notifyListeners();
    }
  }

  Future<void> testTriggerAlert(String alertId) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      final alert = _alerts[index];
      await NotificationService.triggerDestinationAlarm(alert);
      _alerts[index] = alert.copyWith(
        isTriggered: true,
        triggeredAt: DateTime.now(),
      );
      await StorageService.saveAlerts(_alerts);
      notifyListeners();
    }
  }

  Future<void> resetAlert(String alertId) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      await NotificationService.resetAlert(alertId);
      _alerts[index] = _alerts[index].copyWith(isTriggered: false);
      await StorageService.saveAlerts(_alerts);
      notifyListeners();
    }
  }

  /// Calculates proximity metrics (distance in km and remaining minutes) for a given alert
  Map<String, double> getProximityForAlert(TrainAlert alert) {
    final train = _trains.firstWhere(
      (t) => t.id == alert.trainId,
      orElse: () => _selectedTrain ?? _trains.first,
    );

    // Look up target station coordinates
    final station = BangladeshRailwayData.allStations.firstWhere(
      (s) => s.id == alert.targetStationId || s.nameEn == alert.targetStationName,
      orElse: () => train.destination,
    );

    final distanceKm = GpsSimulationService.calculateDistanceKm(
      train.currentPosition.latitude,
      train.currentPosition.longitude,
      station.latitude,
      station.longitude,
    );

    final effectiveSpeed = train.currentSpeedKmh > 10 ? train.currentSpeedKmh : 55.0;
    final remainingMinutes = (distanceKm / effectiveSpeed) * 60.0;

    return {
      'distanceKm': distanceKm,
      'remainingMinutes': remainingMinutes,
    };
  }

  // GPS Simulation controls
  void toggleSimulation() {
    _isSimulating = !_isSimulating;
    if (_isSimulating) {
      _startGpsSimulation();
    } else {
      _simulationTimer?.cancel();
    }
    notifyListeners();
  }

  void setSpeedFactor(double factor) {
    _simSpeedFactor = factor;
    notifyListeners();
  }

  void setTrackingStatus(TrackingStatus status) {
    if (_selectedTrain != null) {
      final updated = _selectedTrain!.copyWith(trackingStatus: status);
      _updateTrainInList(updated);
      _selectedTrain = updated;
      notifyListeners();
    }
  }

  void _startGpsSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!_isSimulating) return;

      final updatedList = <Train>[];
      for (final train in _trains) {
        if (train.trackingStatus == TrackingStatus.offline) {
          updatedList.add(train);
          continue;
        }

        RailwayRoute route = BangladeshRailwayData.dhakaChittagongRoute;
        if (train.destination.id == 'SYL' || train.origin.id == 'SYL') {
          route = BangladeshRailwayData.dhakaSylhetRoute;
        } else if (train.destination.id == 'RAJ' || train.origin.id == 'RAJ') {
          route = BangladeshRailwayData.dhakaRajshahiRoute;
        }

        final updatedTrain = GpsSimulationService.stepTrainSimulation(
          train: train,
          route: route,
          stepSpeedFactor: _simSpeedFactor,
        );
        updatedList.add(updatedTrain);

        if (_selectedTrain?.id == updatedTrain.id) {
          _selectedTrain = updatedTrain;
        }
      }

      _trains = updatedList;

      // Evaluate active Destination Alarms
      _evaluateAlarms();

      notifyListeners();
    });
  }

  void _evaluateAlarms() {
    if (_alerts.isEmpty) return;

    for (final alert in List<TrainAlert>.from(_alerts)) {
      if (!alert.isActive || alert.isTriggered) continue;

      final metrics = getProximityForAlert(alert);
      final distKm = metrics['distanceKm'] ?? 999.0;
      final mins = metrics['remainingMinutes'] ?? 999.0;

      // Evaluate condition with single-trigger duplicate protection
      NotificationService.evaluateProximity(
        alert: alert,
        remainingMinutes: mins,
        remainingDistanceKm: distKm,
      ).then((didTrigger) {
        if (didTrigger) {
          final currentIdx = _alerts.indexWhere((a) => a.id == alert.id);
          if (currentIdx != -1) {
            _alerts[currentIdx] = _alerts[currentIdx].copyWith(
              isTriggered: true,
              triggeredAt: DateTime.now(),
            );
            StorageService.saveAlerts(_alerts);
            notifyListeners();
          }
        }
      });
    }
  }

  void _updateTrainInList(Train updated) {
    final index = _trains.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _trains[index] = updated;
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }
}
