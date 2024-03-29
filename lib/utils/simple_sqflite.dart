import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flash_study/objects/flashcard.dart';
import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flash_study/objects/list_of_sets.dart';
import 'package:flash_study/data/user_data.dart';

class SimpleSqflite {
  static const int _version = 1;
  static const _databaseName = "FlashStudy.db";


  /// Creates the database tables in SQLite if they do not exist.
  static Future<void> createDatabaseTables(Database db) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS Sets (
        setIndex INTEGER,
        name TEXT
      )
    """);

    await db.execute("""
      CREATE TABLE IF NOT EXISTS Flashcards (
        setName TEXT,
        cardIndex INTEGER,
        front TEXT,
        back TEXT,
        FOREIGN KEY (setName) REFERENCES Sets(name) ON DELETE CASCADE
      )
    """);
  }


  /// Retrieves the database.
  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), _databaseName),
      onCreate: (db, version) async {
        await createDatabaseTables(db);
      },
      version: _version
    );
  }


  /// Clears all of the tables in the database.
  static Future<void> clearDatabase() async {
    final db = await _getDB();

    await db.execute("DELETE FROM Flashcards");
    await db.execute("DELETE FROM Sets");
  }


  /// Adds every flashcard set and flashcard into the database.
  static Future<void> addAll() async {
    for (FlashcardSet set in UserData.listOfSets.sets) {
      await addSet(set);
      for (Flashcard card in set.flashcards) {
        await addFlashcard(card);
      }
    }
  }



  // Functions for Flashcard Sets.
  /// Adds a flashcard set into the database.
  static Future<int> addSet(FlashcardSet cardSet) async {
    final db = await _getDB();

    return await db.insert("Sets", cardSet.sqlToJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }


  /// Updates existing information in the database for a flashcard set.
  static Future<int> updateSet(FlashcardSet cardSet) async {
    final db = await _getDB();

    return await db.update("Sets", cardSet.sqlToJson(),
        where: "name = ?",
        whereArgs: [cardSet.name],
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }


  /// Updates the name of an existing flashcard set in the database.
  static Future<int> updateSetName(String oldName, FlashcardSet cardSet) async {
    final db = await _getDB();

    return await db.update("Sets", cardSet.sqlToJson(),
        where: "name = ?",
        whereArgs: [oldName],
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }


  /// Deletes a flashcard set from the database (returns the deleted set).
  static Future<int> deleteSet(FlashcardSet deletedSet) async {
    final db = await _getDB();

    for (int i = deletedSet.flashcards.length - 1; i >= 0; --i) {
      deleteCard(deletedSet, i);
    }

    int result =  await db.delete("Sets",
        where: "name = ?",
        whereArgs: [deletedSet.name]
    );

    // Update indexes.
    updateSetsIndex(deletedSet.index!);

    return result;
  }


  /// Updates the indexes of sets after a set was deleted.
  static Future<void> updateSetsIndex(int deletedAt) async {
    int? numberOfSets = UserData.listOfSets.length();

    // Deleted index was the last item, nothing to fix.
    if (deletedAt >= numberOfSets) {
      return;
    }

    final db = await _getDB();

    // Update every index after the deleted index.
    for (int i = deletedAt; i < numberOfSets; ++i) {
      db.update("Sets", UserData.listOfSets.sets[i].sqlToJson(),
        where: "setIndex = ?",
        whereArgs: [i + 1]
      );
    }
  }


  /// Loads every set from the database into the program.
  static Future<void> loadSets() async {
    if (!UserData.LOAD_SQLITE) {
      return;
    }

    final db = await _getDB();

    // Load sets.
    final List<Map<String, dynamic>> setsJson = await db.query(
      "Sets",
      orderBy: "setIndex ASC"
    );
    final List<Map<String, dynamic>> cardsJson = await db.query(
      "Flashcards",
      orderBy: "cardIndex ASC"
    );
    if (setsJson.isEmpty) {
      return;
    }
    ListOfSets setsList = ListOfSets.sqfliteFromJson(setsJson, cardsJson);

    UserData.overwriteSet(setsList);
  }


  /// Updates two sets in the database if they were swapped.
  static Future<bool> updateSwappedSets(int setIndex1, int setIndex2) async {
    // Any setIndex out of bounds, cancel operation.
    if (setIndex1 < 0) {
      return false;
    }
    if (setIndex2 < 0) {
      return false;
    }
    if (setIndex1 >= UserData.listOfSets.length()) {
      return false;
    }
    if (setIndex2 >= UserData.listOfSets.length()) {
      return false;
    }
    // Indexes are the same, no need to swap.
    if (setIndex1 == setIndex2) {
      return false;
    }

    updateSet(UserData.listOfSets.sets[setIndex1]);
    updateSet(UserData.listOfSets.sets[setIndex2]);

    return true;
  }


  // Functions for flashcards.
  /// Adds a flashcard into the database.
  static Future<int> addFlashcard(Flashcard card) async {
    final db = await _getDB();

    return await db.insert("Flashcards", card.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }


  /// Updates an existing flashcard in the database.
  static Future<int> updateFlashcard(Flashcard card) async {
    final db = await _getDB();
    return await db.update("Flashcards", card.toJson(),
        where: "setName = ? and cardIndex = ?",
        whereArgs: [card.flashcardSet?.name, card.index],
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }


  /// Deletes a flashcard from the database.
  static Future<int> deleteCard(FlashcardSet set, int index) async {
    final db = await _getDB();

    int result = await db.delete("Flashcards",
        where: "cardIndex = ? and setName = ?",
        whereArgs: [index, set.name]
    );

    // Update indexes.
    updateCardsIndex(set, index);

    return result;
  }


  /// Updates two flashcards in the database that were swapped.
  static Future<void> updateSwappedCards(FlashcardSet set,
           int cardIndex1, int cardIndex2) async {
    // Any cardIndex lower than lower bound, cardIndex = last index.
    if (cardIndex1 < 0) {
      cardIndex1 = set.numberOfCards - 1;
    }
    if (cardIndex2 < 0) {
      cardIndex2 = set.numberOfCards - 1;
    }
    // Any cardIndex higher than higher bound, cardIndex = first index.
    if (cardIndex1 >= set.numberOfCards) {
      cardIndex1 = 0;
    }
    if (cardIndex2 >= set.numberOfCards) {
      cardIndex2 = 0;
    }
    // Indexes are the same, no need to swap.
    if (cardIndex1 == cardIndex2) {
      return;
    }

    updateFlashcard(set.flashcards[cardIndex1]);
    updateFlashcard(set.flashcards[cardIndex2]);
  }


  /// Updates the indexes of the flashcards after a set was deleted.
  static Future<void> updateCardsIndex(FlashcardSet set, int deletedAt) async {
    int? numberOfCards = set.numberOfCards;

    // Deleted index was the last item, nothing to fix.
    if (deletedAt >= numberOfCards) {
      return;
    }

    final db = await _getDB();

    // Update every index after the deleted index.
    for (int i = deletedAt; i < numberOfCards; ++i) {
      db.update("Flashcards", set.flashcards[i].toJson(),
          where: "cardIndex = ? and setName = ?",
          whereArgs: [i + 1, set.name]
      );
    }
  }
}
