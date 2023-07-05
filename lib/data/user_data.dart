import 'package:flash_study/objects/list_of_sets.dart';
import 'package:flutter/material.dart';


// Contains data for the user.
class UserData {
  // [DEBUG]
  static const bool LOAD_PREFERENCES = true;  // Local DB (Settings).
  static const bool LOAD_FIRESTORE = true;    // Online DB (Everything).
  static const bool LOAD_SQLITE = true;       // Local DB (Flashcards).



  // Normal variables.
  static ThemeMode currentTheme = ThemeMode.light;
  static bool isDarkMode = false;
  static ListOfSets listOfSets = ListOfSets();



  // Functions.
  /// Overwrites the list of sets with a new one.
  static Future<void> overwriteSet(ListOfSets set) async {
    listOfSets = set;
  }

  /// Retrieves the number of sets in the list.
  static int getNumberOfSets() {
    return listOfSets.length();
  }

  /// Retrieves the current theme.
  static ThemeMode getTheme() {
    return UserData.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  /// Updates the current theme.
  static void updateTheme() {
    currentTheme = getTheme();
  }
}
