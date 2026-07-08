import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  bool _outbreakAlerts = true;
  bool _careReminders = false;
  String _selectedTheme = 'Nature Gradient (Light)';
  String _selectedUnit = 'Celsius (°C)';
  double _cacheSizeMB = 14.2;

  bool get outbreakAlerts => _outbreakAlerts;
  bool get careReminders => _careReminders;
  String get selectedTheme => _selectedTheme;
  String get selectedUnit => _selectedUnit;
  double get cacheSizeMB => _cacheSizeMB;

  bool get isDarkMode => _selectedTheme == 'Midnight Forest (Dark)';

  SettingsService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _outbreakAlerts = prefs.getBool('outbreak_alerts') ?? true;
      _careReminders = prefs.getBool('care_reminders') ?? false;
      _selectedTheme = prefs.getString('selected_theme') ?? 'Nature Gradient (Light)';
      _selectedUnit = prefs.getString('selected_unit') ?? 'Celsius (°C)';
      _cacheSizeMB = prefs.getDouble('cache_size_mb') ?? 14.2;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading settings: $e");
    }
  }

  Future<void> setOutbreakAlerts(bool value) async {
    _outbreakAlerts = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('outbreak_alerts', value);
    } catch (e) {
      debugPrint("Error saving setting: $e");
    }
  }

  Future<void> setCareReminders(bool value) async {
    _careReminders = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('care_reminders', value);
    } catch (e) {
      debugPrint("Error saving setting: $e");
    }
  }

  Future<void> setSelectedTheme(String value) async {
    _selectedTheme = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_theme', value);
    } catch (e) {
      debugPrint("Error saving theme: $e");
    }
  }

  Future<void> setSelectedUnit(String value) async {
    _selectedUnit = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_unit', value);
    } catch (e) {
      debugPrint("Error saving unit: $e");
    }
  }

  Future<void> clearCache() async {
    _cacheSizeMB = 0.0;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('cache_size_mb', 0.0);
    } catch (e) {
      debugPrint("Error clearing cache setting: $e");
    }
  }

  Future<void> increaseCacheSize(double value) async {
    _cacheSizeMB += value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('cache_size_mb', _cacheSizeMB);
    } catch (e) {
      debugPrint("Error updating cache size: $e");
    }
  }

  // Regex utility to dynamically convert text temperature Celsius degrees into Fahrenheit
  static String convertTemperatureString(String text, bool isFahrenheit) {
    if (!isFahrenheit) return text;
    // Regex to match Celsius values like "16-24°C" or "25°C" or "16 - 24 °C"
    final regex = RegExp(r'(\d+)\s*(?:-\s*(\d+))?\s*°\s*C');
    return text.replaceAllMapped(regex, (match) {
      final val1 = int.parse(match.group(1)!);
      final f1 = (val1 * 1.8 + 32).round();
      if (match.group(2) != null) {
        final val2 = int.parse(match.group(2)!);
        final f2 = (val2 * 1.8 + 32).round();
        return '$f1-$f2°F';
      }
      return '$f1°F';
    });
  }
}
