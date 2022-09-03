import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miserend/near_churches_page.dart';
import 'package:path/path.dart';
import "package:sqflite/sqflite.dart";
import 'main.dart';

class RouteSplash extends StatefulWidget {
  const RouteSplash({super.key});

  @override
  _RouteSplashState createState() => _RouteSplashState();
}

class _RouteSplashState extends State<RouteSplash> {
  bool shouldProceed = false;

  _fetchPrefs() async {
    bool fileExists = await File(join(await getDatabasesPath(), 'miserend.sqlite3')).exists();
    if (fileExists) {
      _goToMainScreen();
    } else {
      String response = await downloadFile(
          "https://miserend.hu/fajlok/sqlite/miserend_v4.sqlite3",
          "miserend.sqlite3", await getDatabasesPath());
      _goToMainScreen();
    }
  }

  _goToMainScreen() {
    Navigator.push(
      this.context,
      MaterialPageRoute(builder: (context) => const NearChurchesPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchPrefs();//running initialisation code; getting prefs etc.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator()//show splash screen here instead of progress indicator
      ),
    );
  }

  Future<String> downloadFile(String url, String fileName, String dir) async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if(response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName';
        file = File(filePath);
        await file.writeAsBytes(bytes);
      }
      else {
        filePath = 'Error code: '+response.statusCode.toString();
      }
    }
    catch(ex){
      filePath = 'Can not fetch url';
    }

    return filePath;
  }
}