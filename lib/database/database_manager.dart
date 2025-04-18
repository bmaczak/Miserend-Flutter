import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../preferences.dart';

class DatabaseManager
{
  static final int _databaseCheckPeriodInMillis = 1000 * 60 * 60 * 24 * 7;
  static final String _databaseFileName = 'miserend.sqlite3';
  static final int _databaseVersion = 4;

   static Future<String> get databaseFilePath async {
    return join(await getDatabasesPath(), _databaseFileName);
  }

  static Future<bool> get databaseExists async
  {
    return await File(await databaseFilePath).exists();
  }

  static Future<bool> checkDatabaseVersion() async
  {
    var savedVersion = await Preferences.getDatabaseVersion();
    return savedVersion == _databaseVersion;
  }

  static Future<bool> isDatabaseUpToDate() async
  {
    var lastUpdate = await Preferences.getDatabaseLastUpdated();
    if (lastUpdate == null) {
      return false;
    }
    return DateTime.now().millisecondsSinceEpoch - lastUpdate < _databaseCheckPeriodInMillis;
  }

  static Future<bool> downloadDatabase() async
  {
    return _downloadFile(
        "https://miserend.hu/fajlok/sqlite/miserend_v4.sqlite3",
        _databaseFileName, await getDatabasesPath());
  }

   static Future<bool> _downloadFile(String url, String fileName, String dir) async {
     HttpClient httpClient = HttpClient();
     File file;
     try {
       var request = await httpClient.getUrl(Uri.parse(url));
       var response = await request.close();
       if(response.statusCode == 200) {
         var bytes = await consolidateHttpClientResponseBytes(response);
         var filePath = '$dir/$fileName';
         file = File(filePath);
         await file.writeAsBytes(bytes);
         await Preferences.setDatabaseVersion(_databaseVersion);
         await Preferences.setDatabaseLastUpdated(DateTime.now().millisecondsSinceEpoch);
         return true;
       }
       else {
         return false;
       }
     }
     catch(ex){
       return false;
     }
   }
}