import 'package:shared_preferences/shared_preferences.dart';
import 'package:flash_study/data/user_data.dart';


/// Easier usage of Shared Preferences.
class SimplePreferences {
  static late SharedPreferences _preferences;

  static const _keyIsDarkMode = "isDarkMode";


  /// Initialize the shared preferences database.
  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();


  /// Save all of the preferences into the database.
  static Future<void> saveAll() async {
    await _preferences.setBool(_keyIsDarkMode, UserData.isDarkMode);
  }


  /// Sets the isDarkMode in the database to a value.
  static Future setDarkMode(bool isDarkMode) async =>
      await _preferences.setBool(_keyIsDarkMode, isDarkMode);


  /// Retrieves the isDarkMode value from the database.
  static bool? getDarkMode() => _preferences.getBool(_keyIsDarkMode);
}