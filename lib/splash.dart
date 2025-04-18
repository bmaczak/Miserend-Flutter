import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miserend/database/database_manager.dart';
import 'package:miserend/home/home.dart';

class RouteSplash extends StatefulWidget {
  const RouteSplash({super.key});

  @override
  _RouteSplashState createState() => _RouteSplashState();
}

class _RouteSplashState extends State<RouteSplash> {
  bool shouldProceed = false;

  _checkDatabase() async {
    bool fileExists = await DatabaseManager.databaseExists;
    if (!fileExists) {
      _showDialog(
        "Adatabázis nem taláható",
        "Az alkalmazás használatához szükség van az adatbázis letöltésére. Letölti most?",
        true,
      );
      return;
    }

    bool databaseVersionCompatible =
        await DatabaseManager.checkDatabaseVersion();
    if (!databaseVersionCompatible) {
      _showDialog(
        "Adatbázis nem megfelelő",
        "Az alkalmazás használatához szükség van az adatbázis letöltésére. Letölti most?",
        true,
      );
      return;
    }

    bool isDatabaseUpToDate = await DatabaseManager.isDatabaseUpToDate();
    if (!isDatabaseUpToDate) {
      _showDialog(
        "Frissítés elérhető",
        "Elérhető frisebb adatbázis. Letölti most?",
        false,
      );
      return;
    }

    _goToMainScreen();
  }

  _downloadDatabase() async {
    bool success = await DatabaseManager.downloadDatabase();
    if (success) {
      if (context.mounted) {
        const snackBar = SnackBar(content: Text('Adatbázis frissítés sikeres'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      _goToMainScreen();
    } else {
      if (context.mounted) {
        const snackBar = SnackBar(content: Text('Adatbázis frissítése sikertelen'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  _goToMainScreen() {
    Navigator.pushReplacement(
      this.context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkDatabase(); //running initialisation code; getting prefs etc.
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), //show splash screen here instead of progress indicator
      ),
    );
  }

  Future<void> _showDialog(
    String title,
    String description,
    bool forced,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: <Widget>[
            TextButton(
              child: const Text('Nem'),
              onPressed: () {
                if (forced) {
                  SystemNavigator.pop();
                } else {
                  Navigator.of(context).pop();
                  _goToMainScreen();
                }
              },
            ),
            TextButton(
              child: const Text('Igen'),
              onPressed: () {
                Navigator.of(context).pop();
                _downloadDatabase();
              },
            ),
          ],
        );
      },
    );
  }
}
