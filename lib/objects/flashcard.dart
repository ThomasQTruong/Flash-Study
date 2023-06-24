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


  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      flashcardSet: UserData.listOfSets.getByName(json["setName"]),
      index: json["cardIndex"],
      front: json["front"],
      back: json["back"]
    );
  }


  Map<String, dynamic> toJson() => {
    "setName": flashcardSet?.name ?? "",
    "cardIndex": index,
    "front": front,
    "back": back
  };
}
