import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_study/data/user_data.dart';
import 'package:flash_study/objects/list_of_sets.dart';
import 'package:flash_study/utils/simple_preferences.dart';

class SimpleFirebase {
  static bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }


  static DocumentReference<Map<String, dynamic>> getPreferencesFirestore() {
    return FirebaseFirestore.instance.collection("preferences")
        .doc(FirebaseAuth.instance.currentUser?.uid);
  }


  static DocumentReference<ListOfSets> getSetsFirestore() {
    return FirebaseFirestore.instance.collection("sets").withConverter(
      fromFirestore: ListOfSets.firestoreFromJson,
      toFirestore: (ListOfSets setList, _) => setList.firestoreToJson()
    ).doc(FirebaseAuth.instance.currentUser?.uid);
  }


  static Future<void> savePreferences() async {
    // Update Firebase storage if user is logged in.
    if (isLoggedIn()) {
      final docRef = getPreferencesFirestore();
      await docRef.set(
        {
          "isDarkMode": UserData.isDarkMode
        }
      );
    }
  }


  static Future<void> saveSets() async {
    // Update Firebase storage if user is logged in.
    if (isLoggedIn()) {
      await getSetsFirestore().set(UserData.listOfSets);
    }
  }


  static Future<void> loadSets() async {
    if (!UserData.LOAD_FIRESTORE) {
      return;
    }

    // Update Firebase storage if user is logged in.
    if (isLoggedIn()) {
      final docSnap = await getSetsFirestore().get();
      await UserData.overwriteSet(docSnap.data()!);
    }
  }


  static Future<void> loadPreferences() async {
    if (!UserData.LOAD_FIRESTORE) {
      return;
    }

    await getPreferencesFirestore().get().then((docSnapshot) async {
      // Found data in account.
      if (docSnapshot.exists) {
        UserData.isDarkMode = await docSnapshot.data()?["isDarkMode"];
        // Sync data with local.
        SimplePreferences.setDarkMode(UserData.isDarkMode);
      } else {
        // Did not find data in account; throw exception.
        throw FirebaseAuthException(code: "No data found.");
      }
    }).catchError((_) {
      // Something went wrong/data or account doesn't exist; try local.
      if (!UserData.LOAD_PREFERENCES) {
        return;
      }

      if (SimplePreferences.getDarkMode() != null) {
        UserData.isDarkMode = SimplePreferences.getDarkMode() ?? false;
      }
    });
  }
}
