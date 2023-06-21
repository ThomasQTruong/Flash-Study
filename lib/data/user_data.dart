import 'package:flash_study/objects/list_of_sets.dart';
import 'package:flutter/material.dart';

class UserData {
  static ThemeMode currentTheme = ThemeMode.light;
  static bool isDarkMode = false;
  static ListOfSets listOfSets = ListOfSets();


  static ThemeMode getTheme() {
    return UserData.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }


  static void updateTheme() {
    currentTheme = getTheme();
  }
}
