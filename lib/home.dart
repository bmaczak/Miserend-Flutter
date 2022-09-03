import 'package:flutter/material.dart';

import 'churches_page.dart';
import 'near_churches_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    ChurchesPage(),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Miserend'),
        actions: <Widget>[
          IconButton( icon: const Icon(Icons.search), tooltip: 'Keresés', onPressed: _search, ),],
        ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.church),
            label: 'Templomok',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Misék',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Térkép',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        onTap: _onItemTapped,
      ),
    );
  }

  void _search() {

  }
}