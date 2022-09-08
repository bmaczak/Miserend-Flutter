import 'package:miserend/database/favorite.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static const String databaseName = "localdatabase.sqlite3";

  static const String favoritesTable = "favorites";

  late Database db;

  static Future<LocalDatabase> create() async {
    LocalDatabase instance = LocalDatabase();
  await instance.openDb();
  return instance;
  }

  Future<void> openDb() async {
    db = await openDatabase(join(await getDatabasesPath(), databaseName),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $favoritesTable(id INTEGER PRIMARY KEY, tid INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<List<Favorite>> getFavorites() async {
    final List<Map<String, dynamic>> maps = await db.query(favoritesTable);
    return List.generate(maps.length, (i) {
      return Favorite(churchId: maps[i]['tid']);
    });
  }
  
  Future<bool> isFavorite(int churchId) async {
    int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $favoritesTable WHERE tid=$churchId')) ?? 0;
    return count > 0;
  }

  Future<void> addFavorite(int churchId) async {
    await db.insert(
      favoritesTable,
      Favorite(churchId: churchId).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<void> removeFavorite(int churchId) async {
    await db.delete(
      favoritesTable,
      where: 'tid = ?',
      whereArgs: [churchId],
    );
  }
}