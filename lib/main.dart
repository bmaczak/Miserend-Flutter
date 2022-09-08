import 'package:flutter/material.dart';
import 'package:miserend/colors.dart';
import 'package:miserend/database/favorites_service.dart';
import 'package:miserend/splash.dart';
import 'package:provider/provider.dart';

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
        primarySwatch: CustomColors.purple,
      ),
      home: const RouteSplash(),
    );
  }
}
