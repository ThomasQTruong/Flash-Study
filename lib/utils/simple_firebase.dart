import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_study/data/user_data.dart';
import 'package:flash_study/utils/simple_preferences.dart';

class SimpleFirebase {
  static bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }


  static DocumentReference<Map<String, dynamic>> getUsersFireStore() {
    return FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid);
  }


  static Future<void> saveDarkMode() async {
    // Update Firebase storage if user is logged in.
    if (isLoggedIn()) {
      DocumentReference<Map<String, dynamic>> usersRef = getUsersFireStore();
      // If user exists in storage, update; else, create.
      await usersRef.get().then((docSnapshot) async {
        if (docSnapshot.exists) {
          await usersRef.update({"darkMode": UserData.isDarkMode});
        } else {
          await usersRef.set({"darkMode": UserData.isDarkMode});
        }
      });
    }
    // Save locally too.
    await SimplePreferences.setDarkMode(UserData.isDarkMode);
  }


  static Future<void> loadData() async {
    await getUsersFireStore().get().then((docSnapshot) async {
      // Found data in account.
      if (docSnapshot.exists) {
        UserData.isDarkMode = await docSnapshot.data()?["darkMode"];
        // Sync data with local.
        SimplePreferences.setDarkMode(UserData.isDarkMode);
      } else {
        // Did not find data in account; throw exception.
        throw FirebaseAuthException(code: "No data found.");
      }
    }).catchError((_) {
      // Something went wrong/data or account doesn't exist; try local.
      if (SimplePreferences.getDarkMode() != null) {
        UserData.isDarkMode = SimplePreferences.getDarkMode() ?? false;
      }
    });
  }


  static Future<void> saveSet() async {
    // Update Firebase storage if user is logged in.
    if (isLoggedIn()) {
      DocumentReference<Map<String, dynamic>> usersRef = getUsersFireStore();
      // If user exists in storage, update; else, create.
      await usersRef.get().then((docSnapshot) async {
        if (docSnapshot.exists) {
          await usersRef.update({"darkMode": UserData.isDarkMode});
        } else {
          await usersRef.set({"darkMode": UserData.isDarkMode});
        }
      });
    }
    // Save locally too.
    await SimplePreferences.setDarkMode(UserData.isDarkMode);
  }
}
