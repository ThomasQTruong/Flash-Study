import 'package:flash_study/objects/list_of_sets.dart';
import 'package:flutter/material.dart';

class UserData {
  // [DEBUG]
  static const bool LOAD_PREFERENCES = true;  // Local DB (Settings).
  static const bool LOAD_FIRESTORE = true;    // Online DB (Everything).
  static const bool LOAD_SQLITE = true;       // Local DB (Flashcards).


  // Normal variables.
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
