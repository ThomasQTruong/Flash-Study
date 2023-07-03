import 'package:flash_study/objects/flashcard.dart';
import 'package:flash_study/data/user_data.dart';

/// flashcard_set.dart
///
/// A set of flashcards.
class FlashcardSet {
  int? index;
  String name;
  int numberOfCards = 0;
  List<Flashcard> flashcards = List.empty(growable: true);


  FlashcardSet({required this.index, required this.name});
  FlashcardSet.importLoad({required this.name, required this.flashcards}) {
    index = UserData.listOfSets.length();
    numberOfCards = flashcards.length;
  }
  FlashcardSet.firestoreLoad({required this.index, required this.name,
                                                   required this.flashcards}) {
    numberOfCards = flashcards.length;
  }

  // File import/export.
  Map<String, dynamic> exportToJson() => {
    "name": name,
    "flashcards": cardToJson()
  };


  factory FlashcardSet.importFromJson(Map<String, dynamic> json) {
    List<Flashcard> loadedCards = List.empty(growable: true);

    return FlashcardSet.importLoad(
      name: json["name"],
      flashcards: loadedCards
    );
  }


  // Firebase firestore.
  factory FlashcardSet.firestoreFromJson(Map<String, dynamic> json) {
    List<Flashcard> loadedCards = List.empty(growable: true);

    for (var cardJson in List.of(json["flashcards"])) {
      loadedCards.add(Flashcard.firestoreFromJson(cardJson));
    }

    return FlashcardSet.firestoreLoad(
      index: json["setIndex"],
      name: json["name"],
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
  Future<void> add(Flashcard card) async {
    flashcards.add(card);
    ++numberOfCards;
  }


  Future<Flashcard> create({String front = "", String back = ""}) async {
    Flashcard toAdd = Flashcard(
        flashcardSet: this,
        index: numberOfCards,
        front: front,
        back: back
    );
    flashcards.add(toAdd);
    ++numberOfCards;

    return toAdd;
  }


  Future<Flashcard> delete({required int index}) async {
    --numberOfCards;
    return flashcards.removeAt(index);
  }


  Future<void> swap({required int cardIndex1, required int cardIndex2}) async {
    // Any cardIndex lower than lower bound, cardIndex = last index.
    if (cardIndex1 < 0) {
      cardIndex1 = numberOfCards - 1;
    }
    if (cardIndex2 < 0) {
      cardIndex2 = numberOfCards - 1;
    }
    // Any cardIndex higher than higher bound, cardIndex = first index.
    if (cardIndex1 >= numberOfCards) {
      cardIndex1 = 0;
    }
    if (cardIndex2 >= numberOfCards) {
      cardIndex2 = 0;
    }
    // Indexes are the same, no need to swap.
    if (cardIndex1 == cardIndex2) {
      return;
    }

    Flashcard temp = flashcards[cardIndex1];
    // Swap indexes.
    temp.index = cardIndex2;
    flashcards[cardIndex2].index = cardIndex1;
    // Swap sets.
    flashcards[cardIndex1] = flashcards[cardIndex2];
    flashcards[cardIndex2] = temp;
  }


  Future<void> updateIndexes(int deletedIndex) async {
    // Deleted item was the last item, nothing to fix.
    if (deletedIndex >= numberOfCards) {
      return;
    }

    // Update indexes of every item after deleted index.
    for (int i = deletedIndex; i < numberOfCards; ++i) {
      flashcards[i].index = i;
    }
  }
}
