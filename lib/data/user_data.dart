import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flash_study/utils/simple_preferences.dart';
import 'package:flutter/material.dart';

class UserData {
  static ThemeMode currentTheme = ThemeMode.system;
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
    if (isLoggedIn()) {
      getUsersFireStore().get().then((docSnapshot) {
        print("::::::::::::::::::::::::::::::::::::::::::::::IN FIRESTORE");
        // Found a save.
        if (docSnapshot.exists) {
          isDarkMode = docSnapshot.data()?["darkMode"];
          UserData.updateTheme();
          print(":::::::::::::::::::::::::::::::::::::::::LOADED FROM ACCOUNT");
          return;
        }
      }).catchError((error) {
        // Something went wrong.
        return;
      });
    }

    // Not logged in/did not find data in Firestore.
    if (SimplePreferences.getDarkMode() != null) {
      print(":::::::::::::::::::::::::::::::::::::::::LOADED FROM LOCAL");
      isDarkMode = SimplePreferences.getDarkMode()!;
      UserData.updateTheme();
      return;
    }

    // No data to load at all.
    return;
  }
}
