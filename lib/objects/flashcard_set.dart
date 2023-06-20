import 'flashcard.dart';

/// flashcard_set.dart
///
/// A set of flashcards.
class FlashcardSet {
  String name;
  int numberOfCards = 0;
  List<Flashcard> flashcards = List.empty(growable: true);

  FlashcardSet({required this.name});
}
