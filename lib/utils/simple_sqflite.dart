import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flash_study/objects/flashcard_set.dart';

class SimplePreferences {
  static const int _version = 1;
  static const _databaseName = "FlashcardSets.db";


  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), _databaseName),
      onCreate: (db, version) async =>
          await db.execute(""),
          version: _version
    );
  }


  static Future<int> addSet(FlashcardSet cardSet) async {
    final db = await _getDB();

    return await db.insert("", cardSet.toJson(),
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
