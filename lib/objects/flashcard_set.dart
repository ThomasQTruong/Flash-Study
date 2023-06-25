import 'flashcard.dart';

/// flashcard_set.dart
///
/// A set of flashcards.
class FlashcardSet {
  int? index;
  String name;
  int numberOfCards = 0;
  List<Flashcard> flashcards = List.empty(growable: true);


  FlashcardSet({required this.index, required this.name});

  FlashcardSet.firestoreLoad({required this.index, required this.name,
                              required this.numberOfCards, required this.flashcards});


  // Firebase firestore.
  factory FlashcardSet.firestoreFromJson(Map<String, dynamic> json) {
    print("=====================================[FLASHCARDSET]=====================================");
    List<Flashcard> loadedCards = List.empty(growable: true);

    for (var cardJson in List.of(json["flashcards"])) {
      loadedCards.add(Flashcard.fromJson(cardJson));
    }

    return FlashcardSet.firestoreLoad(
      index: json["setIndex"],
      name: json["name"],
      numberOfCards: loadedCards.length,
      flashcards: loadedCards
    );
  }


  List<Map<String, dynamic>> cardToJson() {
    List<Map<String, dynamic>> jsonCards = List.empty(growable: true);

    for (Flashcard card in flashcards) {
      jsonCards.add(card.toJson());
    }

    return jsonCards;
  }


  Map<String, dynamic> firestoreToJson() => {
    "setIndex": index,
    "name": name,
    "flashcards": cardToJson()
  };


  // SQL
  factory FlashcardSet.sqlFromJson(Map<String, dynamic> json) {
    return FlashcardSet(
      index: json["setIndex"],
      name: json["name"]
    );
  }


  Map<String, dynamic> sqlToJson() => {
    "setIndex": index,
    "name": name
  };


  // Regular functions.
  void add(Flashcard card) {
    flashcards.add(card);
    ++numberOfCards;
  }


  void create({String front = "", String back = ""}) {
    flashcards.add(Flashcard(
      flashcardSet: this,
      index: numberOfCards,
      front: front,
      back: back
    ));
    ++numberOfCards;
  }
}
