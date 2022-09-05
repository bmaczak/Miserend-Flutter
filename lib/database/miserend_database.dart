import 'package:geolocator/geolocator.dart';
import 'package:miserend/database/MassWithChurch.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'church.dart';
import 'mass.dart';

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

  Future<List<Church>> getChurches(List<int> churchIds) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM templomok WHERE tid IN (${churchIds.join(",")})');
    return _mapToChurchList(maps);
  }

  Future<List<Church>> getCloseChurches(double latitude, double longitude) async {
    String query = 'SELECT *,((lng-($longitude))*(lng-($longitude)) + (lat-($latitude))*(lat-($latitude))) AS len FROM templomok WHERE lng != 0 AND lat != 0 ORDER BY len ASC';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return _mapToChurchList(maps);
  }

  Future<List<MassWithChurch>> getCloseMasses(double latitude, double longitude) async {
    String query = 'select *,((templomok.lng-($longitude))*(templomok.lng-($longitude)) + (templomok.lat-($latitude))*(templomok.lat-($latitude))) AS len from misek inner join templomok on misek.tid = templomok.tid WHERE templomok.lng != 0 AND templomok.lat != 0 ORDER BY len ASC LIMIT 500';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return List.generate(maps.length, (i) {
      return MassWithChurch(_mapToChurch(maps[i]), _mapToMass(maps[i]));
    });
  }

  List<Church> _mapToChurchList(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) {
      return _mapToChurch(maps[i]);
    });
  }

  Church _mapToChurch(Map<String, dynamic> map) {
    return Church(
        id: map['tid'],
        name: map['nev'],
        commonName: map['ismertnev'],
        isGreek: map['gorog'] == 1,
        lat: map['lat'],
        lon: map['lng'],
        address: map['geocim'],
        city: map['varos'],
        country: map['orszag'],
        county: map['megye'],
        street: map['cim'],
        gettingThere: map['megkozelites'],
        imageUrl: map['kep']);
  }

  Mass _mapToMass(Map<String, dynamic> map) {
    return Mass(
      id: map['mid'],
      churchId: map['tid'],
      day: map['nap'],
      time: map['ido'],
      season: map['idoszak'],
      language: map['nyelv'],
      tags: map['milyen'],
      period: map['periodus'],
      weight: map['suly'],
      startDate: map['datumtol'],
      endDate: map['datumig'],
      comment: map['megjegyzes'],
    );
  }
}
