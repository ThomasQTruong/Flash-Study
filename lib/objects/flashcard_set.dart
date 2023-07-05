import 'package:flash_study/objects/flashcard.dart';
import 'package:flash_study/data/user_data.dart';


/// A set of flashcards.
class FlashcardSet {
  int? index;
  String name;
  int numberOfCards = 0;
  List<Flashcard> flashcards = List.empty(growable: true);



  // Constructors.
  /// Creates a flashcard set normally.
  FlashcardSet({required this.index, required this.name});

  /// Creates a flashcard set with user's import.
  FlashcardSet.importLoad({required this.name, required this.flashcards}) {
    index = UserData.listOfSets.length();
    numberOfCards = flashcards.length;
  }

  /// Creates a flashcard set with the Firestore database data.
  FlashcardSet.firestoreLoad({required this.index, required this.name,
                                                   required this.flashcards}) {
    numberOfCards = flashcards.length;
  }

  /// Loads a flashcard set from user's import.
  factory FlashcardSet.importFromJson(Map<String, dynamic> json) {
    List<Flashcard> loadedCards = List.empty(growable: true);

    return FlashcardSet.importLoad(
        name: json["name"],
        flashcards: loadedCards
    );
  }

  /// Loads a flashcard set from the Firestore database.
  factory FlashcardSet.firestoreFromJson(Map<String, dynamic> json) {
    List<Flashcard> loadedCards = List.empty(growable: true);

    // Get sets.
    FlashcardSet loadedSet = FlashcardSet.firestoreLoad(
        index: json["setIndex"],
        name: json["name"],
        flashcards: loadedCards
    );

    // Get flashcards.
    for (var cardJson in List.of(json["flashcards"])) {
      loadedSet.add(Flashcard.firestoreFromJson(cardJson, loadedSet));
    }

    return loadedSet;
  }

  /// Loads a flashcard set from the SQLite database.
  factory FlashcardSet.sqlFromJson(Map<String, dynamic> json) {
    return FlashcardSet(
        index: json["setIndex"],
        name: json["name"]
    );
  }



  // File import/export.
  /// Converts the flashcard set into a Json for exporting/sharing.
  Map<String, dynamic> exportToJson() => {
    "name": name,
    "flashcards": cardToJson()
  };

  /// Converts the flashcards to json.
  List<Map<String, dynamic>> cardToJson() {
    List<Map<String, dynamic>> jsonCards = List.empty(growable: true);

    for (Flashcard card in flashcards) {
      jsonCards.add(card.toJson());
    }

    return jsonCards;
  }

  /// Converts the flashcard set into a json for the Firestore database.
  Map<String, dynamic> firestoreToJson() => {
    "setIndex": index,
    "name": name,
    "flashcards": cardToJson()
  };

  /// Converts the flashcard set into a json for the SQLite database.
  Map<String, dynamic> sqlToJson() => {
    "setIndex": index,
    "name": name
  };



  // Regular functions.
  /// Adds a flashcard into the set.
  Future<void> add(Flashcard card) async {
    flashcards.add(card);
    ++numberOfCards;
  }

  /// Creates a flashcard in the set.
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

  /// Deletes a flashcard from the set at an index.
  Future<Flashcard> delete({required int index}) async {
    --numberOfCards;
    return flashcards.removeAt(index);
  }

  /// Swaps two flashcards in the set.
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

  /// Updates the indexes of flashcards when a card was deleted.
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
