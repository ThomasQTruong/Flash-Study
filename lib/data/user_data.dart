import 'package:flash_study/objects/list_of_sets.dart';
import 'package:flutter/material.dart';

class UserData {
  static ThemeMode currentTheme = ThemeMode.light;
  static bool isDarkMode = false;
  static ListOfSets listOfSets = ListOfSets();


  static Future<void> overwriteSet(ListOfSets set) async {
    listOfSets = set;
  }


  static int getNumberOfSets() {
    return listOfSets.length();
  }


  static ThemeMode getTheme() {
    return UserData.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }


  static void updateTheme() {
    currentTheme = getTheme();
  }
}
