import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flash_study/data/user_data.dart';

/// flashcard.dart
///
/// A flashcard.
class Flashcard {
  FlashcardSet? flashcardSet;
  int? index;
  String front;
  String back;


  Flashcard({required this.flashcardSet, required this.index,
                             this.front = "", this.back = ""});


  factory Flashcard.sqlFromJson(FlashcardSet linkedTo, Map<String, dynamic> json) {
    return Flashcard(
        flashcardSet: linkedTo,
        index: json["cardIndex"],
        front: json["front"],
        back: json["back"]
    );
  }


  factory Flashcard.firestoreFromJson(Map<String, dynamic> json, FlashcardSet setLinked) {
    return Flashcard(
        flashcardSet: setLinked,
        index: json["cardIndex"],
        front: json["front"],
        back: json["back"]
    );
  }


  factory Flashcard.importFromJson(Map<String, dynamic> json) {
    return Flashcard(
        flashcardSet: UserData.listOfSets.getByName(json["setName"]),
        index: json["cardIndex"],
        front: json["front"],
        back: json["back"]
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "setName": flashcardSet?.name ?? "",
      "cardIndex": index,
      "front": front,
      "back": back
    };
  }
}
