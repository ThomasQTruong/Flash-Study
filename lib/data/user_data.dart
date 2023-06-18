import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flutter/material.dart';

class UserData {
  static bool isDarkMode = false;
  static List<FlashcardSet> listOfSets = List.empty(growable: true);

  static ThemeMode getTheme() {
    return UserData.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  static DocumentReference<Map<String, dynamic>> getUsersFireStore() {
    return FirebaseFirestore.instance.collection("users")
                .doc(FirebaseAuth.instance.currentUser?.uid);
  }

  static bool isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  static bool loadUserData() {
    if (!isUserLoggedIn()) {
      return false;
    }

    getUsersFireStore().get().then((docSnapshot) {
      if (docSnapshot.exists) {
        isDarkMode = docSnapshot.data()?["darkMode"];
        print("=============================MEOOOOOOOOOOOOOOOOOOOOOO: ${docSnapshot.data()?["darkMode"]}");
        print("${isDarkMode}");
        return true;
      } else {
        return false;
      }
    }).catchError((error) {
      return false;
    });

    return false;
  }
}
