import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flash_study/objects/flashcard_set.dart';

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
}
