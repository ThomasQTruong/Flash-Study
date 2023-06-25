import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_study/objects/flashcard_set.dart';

class ListOfSets {
  List<FlashcardSet> sets = List.empty(growable: true);

  ListOfSets();
  ListOfSets.load({required this.sets});

  factory ListOfSets.fromJson(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final json = snapshot.data();
    List<FlashcardSet> loadedSets = List.empty(growable: true);

    for (var setJson in List.from(json?["sets"])) {
      loadedSets.add(FlashcardSet.firestoreFromJson(setJson));
    }

    return ListOfSets.load(sets: loadedSets);
  }


  Map<String, dynamic> toJson() {
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
}
