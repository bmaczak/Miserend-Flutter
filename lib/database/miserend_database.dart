import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'church.dart';

class MiserendDatabase {
  static const String databaseName = "miserend.sqlite3";

  late Database db;

  static Future<MiserendDatabase> create() async {
    MiserendDatabase instance = MiserendDatabase();
    await instance.openDb();
    return instance;
  }

  Future<void> openDb() async {
    db = await openDatabase(join(await getDatabasesPath(), databaseName));
  }

  Future<List<Church>> getAllChurches() async {
    final List<Map<String, dynamic>> maps = await db.query('templomok');

    return List.generate(maps.length, (i) {
      return Church(
          id: maps[i]['tid'],
          name: maps[i]['nev'],
          commonName: maps[i]['ismertnev'],
          isGreek: maps[i]['gorog'] == 1,
          lat: maps[i]['lat'],
          lon: maps[i]['lng'],
          address: maps[i]['geocim'],
          city: maps[i]['varos'],
          country: maps[i]['orszag'],
          county: maps[i]['megye'],
          street: maps[i]['cim'],
          gettingThere: maps[i]['megkozelites'],
          imageUrl: maps[i]['kep']);
    });
  }
}
