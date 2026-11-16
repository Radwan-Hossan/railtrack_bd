import 'package:shared_preferences/shared_preferences.dart';
import '../models/alert.dart';

class StorageService {
  static const String keyFavorites = 'railtrack_favorites';
  static const String keyThemeMode = 'railtrack_theme_mode';
  static const String keyLanguage = 'railtrack_language';
  static const String keyAlerts = 'railtrack_alerts_v2';
  static const String keyTriggeredAlerts = 'railtrack_triggered_alerts';

  // --- Favorite Trains ---
  static Future<List<String>> getFavoriteTrainIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(keyFavorites) ?? ['TR_701', 'TR_787'];
  }

  static Future<void> saveFavoriteTrainIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(keyFavorites, ids);
  }

  // --- Language Preferences ---
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLanguage) ?? 'en';
  }

  static Future<void> saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLanguage, langCode);
  }

  // --- Theme Mode ---
  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyThemeMode) ?? true;
  }

  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyThemeMode, isDark);
  }

  // --- Smart Destination Alerts (Feature 1 Persistence) ---
  static Future<List<TrainAlert>> getSavedAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(keyAlerts);
    if (jsonList == null || jsonList.isEmpty) {
      // Default demo alerts so first-time users can see the feature immediately
      return [
        TrainAlert(
          id: 'alert_suborno_feni',
          trainId: 'TR_701',
          trainName: 'Suborno Express (701)',
          targetStationId: 'FEN',
          targetStationName: 'Feni Junction',
          targetStationNameBn: 'ফেনী জংশন',
          notifyMinutesBefore: 10,
          notifyDistanceKm: 12.0,
          isTriggered: false,
          isDemo: true,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ];
    }

    try {
      return jsonList.map((str) => TrainAlert.fromJson(str)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAlerts(List<TrainAlert> alerts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = alerts.map((a) => a.toJson()).toList();
    await prefs.setStringList(keyAlerts, jsonList);
  }

  static Future<Set<String>> getTriggeredAlertIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(keyTriggeredAlerts) ?? [];
    return list.toSet();
  }

  static Future<void> addTriggeredAlertId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = (prefs.getStringList(keyTriggeredAlerts) ?? []).toSet();
    current.add(id);
    await prefs.setStringList(keyTriggeredAlerts, current.toList());
  }

  static Future<void> removeTriggeredAlertId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = (prefs.getStringList(keyTriggeredAlerts) ?? []).toSet();
    current.remove(id);
    await prefs.setStringList(keyTriggeredAlerts, current.toList());
  }

  static Future<void> clearTriggeredAlertIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyTriggeredAlerts);
  }
}
