import 'package:shared_preferences/shared_preferences.dart';

class SimplePreferences {
  static late SharedPreferences _preferences;

  static const _keyIsDarkMode = "isDarkMode";


  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();


  static Future setDarkMode(bool isDarkMode) async =>
      await _preferences.setBool(_keyIsDarkMode, isDarkMode);


  static bool? getDarkMode() => _preferences.getBool(_keyIsDarkMode);
}