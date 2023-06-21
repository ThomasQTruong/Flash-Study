/// flashcard.dart
///
/// A flashcard.
class Flashcard {
  int index;
  String front;
  String back;


  Flashcard({required this.index, this.front = "", this.back = ""});

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
        index: json["index"],
        front: json["front"],
        back: json["back"]
    );
  }


  Map<String, dynamic> toJson() => {
    "index": index,
    "front": front,
    "back": back
  };
}
