import 'flashcard.dart';

/// flashcard_set.dart
///
/// A set of flashcards.
class FlashcardSet {
  String name;
  int numberOfCards = 0;
  List<Flashcard> flashcards = List.empty(growable: true);


  FlashcardSet({required this.name});
  FlashcardSet.load({required this.name, required this.numberOfCards,
                                            required this.flashcards});

  factory FlashcardSet.fromJson(Map<String, dynamic> json) {
    List<Flashcard> loadedCards = List.empty(growable: true);

    json["flashcards"].forEach((Map<String, dynamic> cardJson) {
      loadedCards.add(Flashcard.fromJson(cardJson));
    });

    return FlashcardSet.load(
        name: json["name"],
        numberOfCards: json["numberOfCards"],
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


  Map<String, dynamic> toJson() => {
    "name": name,
    "numberOfCards": numberOfCards,
    "flashcards": cardToJson()
  };
}
