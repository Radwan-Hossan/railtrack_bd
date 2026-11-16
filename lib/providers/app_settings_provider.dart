import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AppSettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String _languageCode = 'en';

  AppSettingsProvider() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get languageCode => _languageCode;

  Future<void> _loadSettings() async {
    final isDark = await StorageService.isDarkMode();
    final lang = await StorageService.getLanguage();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _languageCode = lang;
    notifyListeners();
  }

  void toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      await StorageService.saveDarkMode(false);
    } else {
      _themeMode = ThemeMode.dark;
      await StorageService.saveDarkMode(true);
    }
    notifyListeners();
  }

  void setLanguage(String code) async {
    _languageCode = code;
    await StorageService.saveLanguage(code);
    notifyListeners();
  }
}
