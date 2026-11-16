import 'dart:async';
import '../models/alert.dart';
import 'storage_service.dart';

class NotificationService {
  static final StreamController<TrainAlert> _alertEventController =
      StreamController<TrainAlert>.broadcast();

  // In-memory set of triggered alert IDs to prevent duplicate notifications during runtime
  static final Set<String> _runtimeTriggeredAlertIds = {};

  static Stream<TrainAlert> get onAlertTriggered => _alertEventController.stream;

  /// Evaluates whether a destination alarm should trigger, enforcing single-trigger protection
  static Future<bool> evaluateProximity({
    required TrainAlert alert,
    required double remainingMinutes,
    required double remainingDistanceKm,
  }) async {
    if (!alert.isActive || alert.isTriggered) return false;

    // Check runtime and persistent triggered cache
    if (_runtimeTriggeredAlertIds.contains(alert.id)) return false;
    final persistedTriggered = await StorageService.getTriggeredAlertIds();
    if (persistedTriggered.contains(alert.id)) {
      _runtimeTriggeredAlertIds.add(alert.id);
      return false;
    }

    // Condition: train is within configured minutes or distance threshold
    final timeConditionMet = remainingMinutes <= alert.notifyMinutesBefore && remainingMinutes >= 0;
    final distanceConditionMet = remainingDistanceKm <= alert.notifyDistanceKm && remainingDistanceKm >= 0;

    if (timeConditionMet || distanceConditionMet) {
      return await triggerDestinationAlarm(alert);
    }

    return false;
  }

  /// Triggers a destination alarm exactly once
  static Future<bool> triggerDestinationAlarm(TrainAlert alert) async {
    if (_runtimeTriggeredAlertIds.contains(alert.id)) {
      return false; // Prevent duplicate notification
    }

    _runtimeTriggeredAlertIds.add(alert.id);
    await StorageService.addTriggeredAlertId(alert.id);

    final triggeredAlert = alert.copyWith(
      isTriggered: true,
      triggeredAt: DateTime.now(),
    );

    _alertEventController.add(triggeredAlert);
    return true;
  }

  /// Resets alert trigger state (e.g. for testing Demo Mode)
  static Future<void> resetAlert(String alertId) async {
    _runtimeTriggeredAlertIds.remove(alertId);
    await StorageService.removeTriggeredAlertId(alertId);
    final prefs = await StorageService.getSavedAlerts();
    final updated = prefs.map((a) {
      if (a.id == alertId) {
        return a.copyWith(isTriggered: false);
      }
      return a;
    }).toList();
    await StorageService.saveAlerts(updated);
  }
}
