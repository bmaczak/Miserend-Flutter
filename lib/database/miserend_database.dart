import 'package:geolocator/geolocator.dart';
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
    return _mapToChurchList(maps);
  }

  Future<List<Church>> getCloseChurches(double latitude, double longitude) async {
    String query = 'SELECT *,((lng-($longitude))*(lng-($longitude)) + (lat-($latitude))*(lat-($latitude))) AS len FROM templomok WHERE lng != 0 AND lat != 0 ORDER BY len ASC';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return _mapToChurchList(maps);
  }

  List<Church> _mapToChurchList(List<Map<String, dynamic>> maps) {
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
