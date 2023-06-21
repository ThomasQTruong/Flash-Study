import 'package:flash_study/objects/flashcard_set.dart';

class ListOfSets {
  List<FlashcardSet> sets = List.empty(growable: true);

  ListOfSets();
  ListOfSets.load({required this.sets});

  factory ListOfSets.fromJson(Map<String, dynamic> json) {
    List<FlashcardSet> loadedSets = List.empty(growable: true);

    json["sets"].forEach((Map<String, dynamic> setJson) {
      loadedSets.add(FlashcardSet.fromJson(setJson));
    });

    return ListOfSets.load(sets: loadedSets);
  }


  List<Map<String, dynamic>> setsToJson() {
    List<Map<String, dynamic>> jsonSets = List.empty(growable: true);

    for (FlashcardSet cardSet in sets) {
      jsonSets.add(cardSet.toJson());
    }

    return jsonSets;
  }


  Map<String, dynamic> toJson() => {
    "sets": setsToJson()
  };


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
