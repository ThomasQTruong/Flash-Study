import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flash_study/objects/flashcard.dart';

class ListOfSets {
  List<FlashcardSet> sets = List.empty(growable: true);


  ListOfSets();
  ListOfSets.load({required this.sets});


  factory ListOfSets.sqfliteFromJson(List<Map<String, dynamic>> setsJson,
                                     List<Map<String, dynamic>> cardsJson) {
    List<FlashcardSet> loadedSets = List.empty(growable: true);

    for (var setJson in setsJson) {
      loadedSets.add(FlashcardSet(
        index: setJson["setIndex"],
        name: setJson["name"]
      ));
    }
    ListOfSets setsList = ListOfSets.load(sets: loadedSets);

    for (var cardJson in cardsJson) {
      FlashcardSet? cardSet = setsList.getByName(cardJson["setName"]);

      cardSet?.add(Flashcard.sqlFromJson(cardSet, cardJson));
    }

    return setsList;
  }


  factory ListOfSets.firestoreFromJson(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final json = snapshot.data();
    List<FlashcardSet> loadedSets = List.empty(growable: true);

    for (var setJson in List.from(json?["sets"])) {
      loadedSets.add(FlashcardSet.firestoreFromJson(setJson));
    }

    return ListOfSets.load(sets: loadedSets);
  }


  Map<String, dynamic> firestoreToJson() {
    List<Map<String, dynamic>> jsonSets = List.empty(growable: true);

    for (FlashcardSet cardSet in sets) {
      jsonSets.add(cardSet.firestoreToJson());
    }

    return {"sets": jsonSets};
  }


  bool isEmpty() {
    return sets.isEmpty;
  }


  int length() {
    return sets.length;
  }


  void add(FlashcardSet cardSet) {
    sets.add(cardSet);
  }


  void setAt(int index, FlashcardSet newCardSet) {
    sets[index] = newCardSet;
  }


  void setNameAt(int index, String newSetName) {
    sets[index].name = newSetName;
  }


  FlashcardSet getAt(int index) {
    return sets[index];
  }


  FlashcardSet getLast() {
    return sets[sets.length - 1];
  }


  String getNameAt(int index) {
    return sets[index].name;
  }


  FlashcardSet? getByName(String setToGet) {
    for (FlashcardSet set in sets) {
      if (set.name == setToGet) {
        return set;
      }
    }

    return null;
  }


  int getNumberOfCardsAt(int index) {
    return sets[index].numberOfCards;
  }


  FlashcardSet removeAt(int index) {
    return sets.removeAt(index);
  }


  bool moveSetUpAt(int index) {
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


  bool moveSetDownAt(int index) {
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


  bool hasSetNamed(String name) {
    for (FlashcardSet aSet in sets) {
      if (aSet.name == name) {
        return true;
      }
    }
    return false;
  }


  void updateIndexes(int deletedIndex) {
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
