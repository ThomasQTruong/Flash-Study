import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flash_study/data/user_data.dart';


/// A flashcard.
class Flashcard {
  FlashcardSet? flashcardSet;
  int? index;
  String front;
  String back;



  // Constructors.
  /// Creates a flashcard normally.
  Flashcard({required this.flashcardSet, required this.index,
                             this.front = "", this.back = ""});

  /// Creates a flashcard with data from the SQLite database.
  factory Flashcard.sqlFromJson(FlashcardSet linkedTo, Map<String, dynamic> json) {
    return Flashcard(
        flashcardSet: linkedTo,
        index: json["cardIndex"],
        front: json["front"],
        back: json["back"]
    );
  }

  /// Creates a flashcard with the data from the Firestore database.
  factory Flashcard.firestoreFromJson(Map<String, dynamic> json, FlashcardSet setLinked) {
    return Flashcard(
        flashcardSet: setLinked,
        index: json["cardIndex"],
        front: json["front"],
        back: json["back"]
    );
  }

  /// Creates a flashcard with the user's imported json.
  factory Flashcard.importFromJson(Map<String, dynamic> json) {
    return Flashcard(
        flashcardSet: UserData.listOfSets.getByName(json["setName"]),
        index: json["cardIndex"],
        front: json["front"],
        back: json["back"]
    );
  }



  // Functions.
  /// Converts the flashcard into a json.
  Map<String, dynamic> toJson() {
    return {
      "setName": flashcardSet?.name ?? "",
      "cardIndex": index,
      "front": front,
      "back": back
    };
  }
}
