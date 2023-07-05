import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flash_study/objects/flashcard.dart';


/// A list of flashcard sets.
class ListOfSets {
  List<FlashcardSet> sets = List.empty(growable: true);



  // Constructors.
  /// Default constructor (empty list).
  ListOfSets();

  /// Loads a given list of sets.
  ListOfSets.load({required this.sets});

  /// Loads the sets from the SQLite database.
  factory ListOfSets.sqfliteFromJson(List<Map<String, dynamic>> setsJson,
                                     List<Map<String, dynamic>> cardsJson) {
    List<FlashcardSet> loadedSets = List.empty(growable: true);

    // For every set in the database, create set.
    for (var setJson in setsJson) {
      loadedSets.add(FlashcardSet(
        index: setJson["setIndex"],
        name: setJson["name"]
      ));
    }
    ListOfSets setsList = ListOfSets.load(sets: loadedSets);

    // For every card in the database, create card.
    for (var cardJson in cardsJson) {
      FlashcardSet? cardSet = setsList.getByName(cardJson["setName"]);

      cardSet?.add(Flashcard.sqlFromJson(cardSet, cardJson));
    }

    return setsList;
  }

  /// Loads sets from the Firestore database.
  factory ListOfSets.firestoreFromJson(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final json = snapshot.data();
    List<FlashcardSet> loadedSets = List.empty(growable: true);

    for (var setJson in List.from(json?["sets"])) {
      loadedSets.add(FlashcardSet.firestoreFromJson(setJson));
    }

    return ListOfSets.load(sets: loadedSets);
  }


  // Functions.
  /// Converts the list of sets into a Json for the Firestore database.
  Map<String, dynamic> firestoreToJson() {
    List<Map<String, dynamic>> jsonSets = List.empty(growable: true);

    for (FlashcardSet cardSet in sets) {
      jsonSets.add(cardSet.firestoreToJson());
    }

    return {"sets": jsonSets};
  }

  /// Whether the list of sets is empty or not.
  bool isEmpty() {
    return sets.isEmpty;
  }

  /// Retrieves the amount of sets in the list.
  int length() {
    return sets.length;
  }

  /// Adds a flashcard set into the list.
  Future<void> add(FlashcardSet cardSet) async {
    sets.add(cardSet);
  }

  /// Replaces a flashcard set at an index with a new set.
  void setAt(int index, FlashcardSet newCardSet) {
    sets[index] = newCardSet;
  }

  /// Sets the name of a flashcard set at an index to a new name.
  void setNameAt(int index, String newSetName) {
    sets[index].name = newSetName;
  }

  /// Retrieves the flashcard set at an index.
  FlashcardSet getAt(int index) {
    return sets[index];
  }

  /// Retrieves the last flashcard set in the list.
  FlashcardSet getLast() {
    return sets[sets.length - 1];
  }

  /// Retrieves the name of the flashcard set at an index.
  String getNameAt(int index) {
    return sets[index].name;
  }

  /// Retrieves a flashcard set by its name.
  FlashcardSet? getByName(String setToGet) {
    for (FlashcardSet set in sets) {
      if (set.name == setToGet) {
        return set;
      }
    }

    return null;
  }

  /// Retrieves the number of cards of a flashcard set at an index.
  int getNumberOfCardsAt(int index) {
    return sets[index].numberOfCards;
  }

  /// Removes a flashcard set at an index from the list.
  Future<FlashcardSet> removeAt(int index) async {
    return sets.removeAt(index);
  }

  /// Moves a flashcard set at an index up in the list (closer to the start).
  Future<bool> moveSetUpAt(int index) async {
    // First set, cannot move any higher.
    if (index <= 0) {
      return false;
    }

    // Switch sets.
    FlashcardSet previousSet = sets[index - 1];
    sets[index - 1] = sets[index];
    sets[index] = previousSet;

    // Update indexes.
    sets[index - 1].index = index - 1;
    sets[index].index = index;

    return true;
  }

  /// Moves a flashcard set at an index down in the list (closer to the end).
  Future<bool> moveSetDownAt(int index) async {
    // Last set, cannot move any lower.
    if (index >= length() - 1) {
      return false;
    }

    // Switch sets.
    FlashcardSet nextSet = sets[index + 1];
    sets[index + 1] = sets[index];
    sets[index] = nextSet;

    // Update indexes.
    sets[index + 1].index = index + 1;
    sets[index].index = index;

    return true;
  }

  /// Checks whether a set with a specific name exists in the list.
  bool hasSetNamed(String name) {
    for (FlashcardSet aSet in sets) {
      if (aSet.name == name) {
        return true;
      }
    }
    return false;
  }

  /// Updates the indexes in the list when a set is deleted.
  Future<void> updateIndexes(int deletedIndex) async {
    // Deleted item was the last item, nothing to fix.
    if (deletedIndex >= length()) {
      return;
    }

    // Update indexes of every item after deleted index.
    for (int i = deletedIndex; i < length(); ++i) {
      sets[i].index = i;
    }
  }
}
