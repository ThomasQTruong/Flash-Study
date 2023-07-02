import 'package:shared_preferences/shared_preferences.dart';
import 'package:flash_study/data/user_data.dart';

class SimplePreferences {
  static late SharedPreferences _preferences;

  static const _keyIsDarkMode = "isDarkMode";


  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();


  static Future<void> saveAll() async {
    await _preferences.setBool(_keyIsDarkMode, UserData.isDarkMode);
  }


  static Future setDarkMode(bool isDarkMode) async =>
      await _preferences.setBool(_keyIsDarkMode, isDarkMode);


  static bool? getDarkMode() => _preferences.getBool(_keyIsDarkMode);
}