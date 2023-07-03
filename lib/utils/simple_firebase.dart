import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_study/data/user_data.dart';
import 'package:flash_study/objects/list_of_sets.dart';
import 'package:flash_study/objects/flashcard_set.dart';
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

    // Load from Firebase storage if user is logged in.
    if (isLoggedIn()) {
      final docSnap = await getSetsFirestore().get();
      await UserData.overwriteSet(docSnap.data()!);
    }
  }


  static Future<void> loginLoadSets() async {
    if (!UserData.LOAD_FIRESTORE) {
      return;
    }

    // Load from Firebase storage if user is logged in.
    if (isLoggedIn()) {
      final docSnap = await getSetsFirestore().get();
      ListOfSets setsList = docSnap.data()!;

      // Case 1: no Firestore data.
      if (setsList.length() == 0) {
        return;
      }

      // Case 2: no local data.
      if (UserData.listOfSets.length() == 0) {
        // Just load from Firestore.
        await UserData.overwriteSet(setsList);
        return;
      }

      // Case 3: Firestore and local have data, merge.
      for (FlashcardSet set in setsList.sets) {
        // Set does not current exist (judged by name).
        if (!UserData.listOfSets.hasSetNamed(set.name)) {
          // Add to local data.
          UserData.listOfSets.add(set);
        }
      }
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
