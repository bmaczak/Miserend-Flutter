import 'dart:convert';

import 'package:miserend/database/MassWithChurch.dart';
import 'package:miserend/database/church_with_masses.dart';
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

  Future<List<ChurchWithMasses>> getChurches(List<int> churchIds) async {

    String query =
        'select t.*, \'[\' || GROUP_CONCAT(\'{"ido":"\' || m.ido || \'", "nap":\' || m.nap || \'}\', \',\') || \']\' AS misek '
        'from templomok as t inner join misek as m on m.tid = t.tid '
        'WHERE t.tid IN (${churchIds.join(",")}) '
        'GROUP BY t.tid ';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return _mapToChurchWithMasses(maps);
  }

  Future<List<Church>> getCloseChurches(
      double latitude, double longitude) async {
    String query =
        'SELECT *,((lng-($longitude))*(lng-($longitude)) + (lat-($latitude))*(lat-($latitude))) AS len FROM templomok WHERE lng != 0 AND lat != 0 ORDER BY len ASC';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return _mapToChurchList(maps);
  }

  Future<List<MassWithChurch>> getCloseMasses(
      double latitude, double longitude) async {
    String query =
        'select *,((templomok.lng-($longitude))*(templomok.lng-($longitude)) + (templomok.lat-($latitude))*(templomok.lat-($latitude))) AS len from misek inner join templomok on misek.tid = templomok.tid WHERE templomok.lng != 0 AND templomok.lat != 0 ORDER BY len ASC LIMIT 500';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return List.generate(maps.length, (i) {
      return MassWithChurch(_mapToChurch(maps[i]), _mapToMass(maps[i]));
    });
  }

  Future<List<ChurchWithMasses>> getCloseChurchesWithMasses(
      double latitude, double longitude) async {
    List<ChurchWithMasses> result = <ChurchWithMasses>[];
    List<String> massFieldNames = <String>[
      'ido', 'nap'
    ];

    String query =
        'select t.*, \'[\' || GROUP_CONCAT(\'{"ido":"\' || m.ido || \'", "nap":\' || m.nap || \'}\', \',\') || \']\' AS misek, '
        '((t.lng-($longitude))*(t.lng-($longitude)) + (t.lat-($latitude))*(t.lat-($latitude))) AS len '
        'from templomok as t inner join misek as m on m.tid = t.tid '
        'WHERE t.lng != 0 AND t.lat != 0 '
        'GROUP BY t.tid '
        'ORDER BY len';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);

    return _mapToChurchWithMasses(maps);
  }

  List<ChurchWithMasses> _mapToChurchWithMasses(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) {
      final List t = json.decode(maps[i]['misek']);
      final List<Mass> masses = t.map((item) => _mapToMass(item)).toList();
      return ChurchWithMasses(_mapToChurch(maps[i]), masses);
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
