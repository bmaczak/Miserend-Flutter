import 'dart:io';
import 'package:flutter/material.dart';
import 'package:miserend/database/church.dart';
import 'package:miserend/database/favorites_service.dart';
import 'package:miserend/database/miserend_database.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'splash.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FavoritesService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        backgroundColor: Colors.grey,
        primarySwatch: Colors.blue,
      ),
      home: const RouteSplash(),
    );
  }
}
