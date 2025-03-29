import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miserend/database/church.dart';
import 'package:miserend/database/mass.dart';
import 'package:miserend/database/mass_with_church.dart';
import 'package:miserend/database/church_with_masses.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class MiserendDatabase {
  static const String databaseName = "miserend.sqlite3";
  static const massesInnerQuery = '\'[\' || GROUP_CONCAT(\'{'
      '"ido":"\' || m.ido || \'", '
      '"nap":\' || m.nap || \', '
      '"datumtol":\' || m.datumtol || \', '
      '"datumig":\' || m.datumig || \', '
      '"periodus":"\' || m.periodus || \'"'
      '}\', \',\') || \']\' AS misek';

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

  Future<List<Church>> getChurchesForSearchTerm(String searchTerm) async {
    String query = 'select * from templomok WHERE nev like \'%${searchTerm}%\' '
        'or ismertnev like \'%${searchTerm}%\'';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return _mapToChurchList(maps);
  }

  Future<List<String>> getCitiesForSearchTerm(String searchTerm) async {
    String query = 'select distinct varos from templomok WHERE varos like \'%${searchTerm}%\'';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return  List.generate(maps.length, (i) {
      return maps[i]['varos'];
    });
  }

  Future<List<ChurchWithMasses>> getChurches(List<int> churchIds) async {

    String query =
        'select t.*, ${massesInnerQuery} from templomok as t left join misek as m on m.tid = t.tid WHERE t.tid IN (${churchIds.join(",")}) GROUP BY t.tid ';
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

  Future<List<Mass>> getMassesForChurch(
      int churchId) async {
    String query = 'select * from misek where tid = $churchId';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return _mapToMassList(maps);
  }

  Future<List<ChurchWithMasses>> getCloseChurchesWithMasses(
      double latitude, double longitude) async {

    String query =
        'select t.*, $massesInnerQuery, '
        '((t.lng-($longitude))*(t.lng-($longitude)) + (t.lat-($latitude))*(t.lat-($latitude))) AS len '
        'from templomok as t left join misek as m on m.tid = t.tid '
        'WHERE t.lng != 0 AND t.lat != 0 '
        'GROUP BY t.tid '
        'ORDER BY len';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);

    return _mapToChurchWithMasses(maps);
  }

  List<ChurchWithMasses> _mapToChurchWithMasses(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) {
      List<Mass> masses = <Mass>[];
      if (maps[i]['misek'] != null) {
        final List t = json.decode(maps[i]['misek']);
        masses = t.map((item) => _mapToMass(item)).toList();
      }
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

  List<Mass> _mapToMassList(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) {
      return _mapToMass(maps[i]);
    });
  }

  Mass _mapToMass(Map<String, dynamic> map) {
    String s = map['ido'];
    TimeOfDay timeOfDay = TimeOfDay(hour:int.parse(s.split(":")[0]),minute: int.parse(s.split(":")[1]));
    return Mass(
      id: map['mid'],
      churchId: map['tid'],
      day: map['nap'],
      time: timeOfDay,
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
