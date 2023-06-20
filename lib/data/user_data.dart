import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flash_study/utils/simple_preferences.dart';
import 'package:flutter/material.dart';

class UserData {
  static ThemeMode currentTheme = ThemeMode.light;
  static bool isDarkMode = false;
  static List<FlashcardSet> listOfSets = List.empty(growable: true);


  static ThemeMode getTheme() {
    return UserData.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }


  static void updateTheme() {
    currentTheme = getTheme();
  }


  static DocumentReference<Map<String, dynamic>> getUsersFireStore() {
    return FirebaseFirestore.instance.collection("users")
                .doc(FirebaseAuth.instance.currentUser?.uid);
  }


  static bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }


  static Future<void> loadData() async {
    await getUsersFireStore().get().then((docSnapshot) async {
      // Found data in account.
      if (docSnapshot.exists) {
        isDarkMode = await docSnapshot.data()?["darkMode"];
        // Sync data with local.
        SimplePreferences.setDarkMode(isDarkMode);
      } else {
        // Did not find data in account; throw exception.
        throw FirebaseAuthException(code: "No data found.");
      }
    }).catchError((_) {
      // Something went wrong/data or account doesn't exist; try local.
      if (SimplePreferences.getDarkMode() != null) {
        isDarkMode = SimplePreferences.getDarkMode() ?? false;
      }
    });
  }


  static Future<void> saveDarkMode() async {
    // Update Firebase storage if user is logged in.
    if (UserData.isLoggedIn()) {
      DocumentReference<Map<String, dynamic>> usersRef = getUsersFireStore();
      // If user exists in storage, update; else, create.
      await usersRef.get().then((docSnapshot) async {
        if (docSnapshot.exists) {
          await usersRef.update({"darkMode": isDarkMode});
        } else {
          await usersRef.set({"darkMode": isDarkMode});
        }
      });
    }
    // Save locally too.
    await SimplePreferences.setDarkMode(isDarkMode);
  }


  static Future<void> saveSet() async {
    // Update Firebase storage if user is logged in.
    if (UserData.isLoggedIn()) {
      DocumentReference<Map<String, dynamic>> usersRef = getUsersFireStore();
      // If user exists in storage, update; else, create.
      await usersRef.get().then((docSnapshot) async {
        if (docSnapshot.exists) {
          await usersRef.update({"darkMode": isDarkMode});
        } else {
          await usersRef.set({"darkMode": isDarkMode});
        }
      });
    }
    // Save locally too.
    await SimplePreferences.setDarkMode(isDarkMode);
  }
}
