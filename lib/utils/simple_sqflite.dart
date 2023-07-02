import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flash_study/objects/flashcard.dart';
import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flash_study/objects/list_of_sets.dart';
import 'package:flash_study/data/user_data.dart';

class SimpleSqflite {
  static const int _version = 1;
  static const _databaseName = "FlashStudy.db";


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


  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), _databaseName),
      onCreate: (db, version) async {
        await createDatabaseTables(db);
      },
      version: _version
    );
  }


  static Future<void> clearDatabase() async {
    final db = await _getDB();

    await db.execute("DELETE FROM Flashcards");
    await db.execute("DELETE FROM Sets");
  }


  static Future<void> addAll() async {
    for (FlashcardSet set in UserData.listOfSets.sets) {
      await addSet(set);
      for (Flashcard card in set.flashcards) {
        await addFlashcard(card);
      }
    }
  }


  // Functions for sets.
  static Future<int> addSet(FlashcardSet cardSet) async {
    final db = await _getDB();

    return await db.insert("Sets", cardSet.sqlToJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }


  static Future<int> updateSet(String oldName, FlashcardSet cardSet) async {
    final db = await _getDB();
    return await db.update("Sets", cardSet.sqlToJson(),
        where: "name = ?",
        whereArgs: [oldName],
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }


  static Future<int> deleteSet(String nameOfSetToDelete) async {
    final db = await _getDB();
    return await db.delete("Sets",
        where: "name = ?",
        whereArgs: [nameOfSetToDelete]
    );
  }


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


  // Functions for flashcards.
  static Future<int> addFlashcard(Flashcard card) async {
    final db = await _getDB();

    return await db.insert("Flashcards", card.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }


  static Future<int> updateFlashcard(Flashcard card) async {
    final db = await _getDB();
    return await db.update("Flashcards", card.toJson(),
        where: "setName = ? and cardIndex = ?",
        whereArgs: [card.flashcardSet?.name, card.index],
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }
}
