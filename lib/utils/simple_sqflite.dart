import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flash_study/objects/flashcard_set.dart';

class SimpleSqflite {
  static const int _version = 1;
  static const _databaseName = "FlashcardSets.db";


  static Future<void> createDatabaseTables(Database db) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS Flashcard_Sets (
        name TEXT,
        numberOfCards INTEGER
      )
    """);

    await db.execute("""
      CREATE TABLE IF NOT EXISTS Flashcards (
        setName TEXT,
        id INTEGER,
        front TEXT,
        back TEXT,
        FOREIGN KEY (setName) REFERENCES flashcard_sets(name) ON DELETE CASCADE
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


  static Future<int> addSet(FlashcardSet cardSet) async {
    final db = await _getDB();

    return await db.insert("Flashcard_Sets", cardSet.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }


  static Future<int> updateSet(FlashcardSet cardSet) async {
    final db = await _getDB();
    return await db.update("", cardSet.toJson(),
      where: "name = ?",
      whereArgs: [cardSet.name],
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }
}
