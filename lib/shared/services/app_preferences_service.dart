import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app preferences, including first launch detection
class AppPreferencesService {
  static const String _keyFirstLaunch = 'is_first_launch';

  /// Check if this is the first time the app is being launched
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  /// Mark that the user has completed the first launch/onboarding
  static Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
  }

  /// Reset first launch status (useful for testing)
  static Future<void> resetFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFirstLaunch);
  }
}
