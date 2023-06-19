import 'package:shared_preferences/shared_preferences.dart';

class SimplePreferences {
  static late SharedPreferences _preferences;

  static const _keyDarkMode = "darkMode";

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setDarkMode(bool isDarkMode) async =>
      await _preferences.setBool(_keyDarkMode, isDarkMode);

  static bool? getDarkMode() => _preferences.getBool(_keyDarkMode);
}