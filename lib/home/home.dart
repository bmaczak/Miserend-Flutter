import 'package:flutter/material.dart';
import 'package:miserend/home/churches/churches_page.dart';
import 'package:miserend/home/masses/near_masses_page.dart';
import 'package:miserend/home/map/map_page.dart';

import '../church_details/church_details_page.dart';
import '../database/church.dart';
import '../database/miserend_database.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

abstract class Suggestion {
  Widget buildWidget(BuildContext context);
}

class ChurchSuggestion extends Suggestion
{
  Church church;

  ChurchSuggestion(this.church);

  Widget _errorBuilder(
      BuildContext context, Object error, StackTrace? stackTrace) {
    return Image.asset('assets/images/church_blurred.png', fit: BoxFit.cover);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return ListTile(
        onTap: () {
          _openDetails(church, context);
        },
        titleAlignment: ListTileTitleAlignment.center,
        leading:  AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: FadeInImage.assetNetwork(
              fit: BoxFit.cover,
              placeholder: 'assets/images/church_blurred.png',
              image: church.imageUrl ?? "",
              imageErrorBuilder: _errorBuilder,
            ),
          ),
        ),
        title: Text(church.name ?? "")
    );
  }

  _openDetails(Church church, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChurchDetailsPage(church: church)),
    );
  }
}

class CitySuggestion extends Suggestion {

  String cityName = "";

  CitySuggestion(this.cityName);

  @override
  Widget buildWidget(BuildContext context) {
    return ListTile(
        titleAlignment: ListTileTitleAlignment.center,
        leading:  AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Icon(
              Icons.location_city,
              color: Colors.black54,
              size: 24.0,
            ),
          ),
        ),
        title: Text(cityName)
    );
  }

}


class _HomeScreenState extends State<HomeScreen> {

  final SearchController _searchController = SearchController();
  int _selectedIndex = 0;

  List<Suggestion> suggestions = <Suggestion>[];

  static const List<Widget> _widgetOptions = <Widget>[
    ChurchesPage(),
    NearMassesPage(),
    MapPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        clipBehavior: Clip.none,
        iconTheme:  IconThemeData(
            color: Colors.black54
        ),
        title: ExcludeFocus(
          child: SizedBox(
            height: 48,
            child: SearchAnchor.bar(
              isFullScreen: false,
            onChanged: _onSearchChanged,
            searchController: _searchController,
            suggestionsBuilder: (BuildContext context, SearchController controller) {
              return List<Widget>.generate(suggestions.length, (int index) {
                return suggestions[index].buildWidget(context);
              });
            },
            ),
          ),
        ),
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

  void _onSearchChanged(String value) async {
    MiserendDatabase db = await MiserendDatabase.create();
    var churches = await db.getChurchesForSearchTerm(value);
    var cities = await db.getCitiesForSearchTerm(value);
    var combined = <Suggestion>[];
    combined.addAll(churches.take(20).map((c) => ChurchSuggestion(c)));
    combined.addAll(cities.map((c) => CitySuggestion(c)));
    setState(() {
      suggestions = combined;
      var value = _searchController.text;
      _searchController.text = "";
      _searchController.text = value;
    });
  }
}