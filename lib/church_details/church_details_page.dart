import 'dart:math';

import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:miserend/database/church.dart';
import 'package:miserend/database/favorites_service.dart';
import 'package:provider/provider.dart';

import '../database/mass.dart';
import '../database/miserend_database.dart';
import '../mass_filter.dart';
import '../widgets/time_chip.dart';
import 'package:intl/intl.dart';

class ChurchDetailsPage extends StatefulWidget {
  const ChurchDetailsPage({super.key, required this.church});

  final Church church;

  @override
  State<ChurchDetailsPage> createState() => _ChurchDetailsPageState();
}

class _ChurchDetailsPageState extends State<ChurchDetailsPage> {

  List<List<Mass>> masses = <List<Mass>>[];

  List<String> nameOfDays = [
    "Hétfő", "Kedd", "Szerda", "Csütörtök", "Péntek", "Szombat", "Vasárnap" 
  ];
  
  var dateFormat = DateFormat('yyyy. MM. dd.');

  var isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadMasses();
    isFavorite = Provider.of<FavoritesService>(context, listen: false).isFavorite(widget.church.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: widget.church.imageUrl?.isNotEmpty ?? false
                      ? FadeInImage.assetNetwork(
                    image: widget.church.imageUrl ?? "",
                    fit: BoxFit.cover,
                    placeholder: 'assets/images/church_blurred.png',
                    imageErrorBuilder: _errorBuilder,
                  )
                      : Image.asset('assets/images/church_blurred.png',
                      fit: BoxFit.cover),
              ),
            ),
          ];
        },
        body: ListView(
          children: [
            _churchName(),
            Container(height: 1, color: Colors.black12,),
            _actionButtons(),
            Container(
              color: Colors.black12,
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _massCard()
                    ],
                  ))
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                color: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      children: List<Widget>.generate(max(masses.length - 1, 0),
                              (index) {
                            return _getMassListCardForDay(index + 1);
                          })
                  ),
                ),
              ),
            ),
            _mapCard()
          ],
        ),
      ),
    );
  }

  Widget _churchName()
  {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
              widget.church.name ?? "",
              style: Theme.of(context).textTheme.titleLarge
          ),
          Text(
              widget.church.commonName ?? "",
              style: Theme.of(context).textTheme.bodyMedium?.apply(color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons()
  {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: [
          GestureDetector(
            onTap: _toggleFavorites,
            child: Column(
              spacing: 8,
              children: [
                Icon(isFavorite ? Icons.favorite : Icons.favorite_border, size: 32, color: Colors.black54),
                Text("Kedvencekhez")
              ],
            ),
          ),
          Column(
            spacing: 8,
            children: [
              Icon(Icons.error, size: 32, color: Colors.black54),
              Text("Hibajelentés")
            ],
          )
        ],
      ),
    );
  }

  Widget _massCard()
  {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text("Ma", style: Theme.of(context).textTheme.titleLarge),
            _massListWidgetForDay(0),
            Text("Most vasárnap", style: Theme.of(context).textTheme.titleLarge),
            _massListWidgetForDay(DateTime.sunday - DateTime.now().weekday),
          ],
        ),
      ),
    );
  }

  Widget _massListWidgetForDay(int offset)
  {
    var hasAny = masses.length > offset;
    return hasAny ? Container(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Wrap(
            spacing: 4,
            children: List<Widget>.generate(masses[offset].length,
                    (index) {
                  return TimeChip(time: masses[offset][index].time);
                })),
      ),
    ) : Container();
  }
  
  Widget _getMassListCardForDay(int dayOffset)
  {
    var hasAny = masses.length > dayOffset;
    if (!hasAny){
      return Container();
    }
    else
    {
      var dateTime = DateTime.now().add(Duration(days: dayOffset));
      var nameOfDay = dayOffset == 1 ? "Holnap" : nameOfDays[dateTime.weekday - 1];
        return Card(
          child: SizedBox(
            width: 160,
            height: 160,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nameOfDay, style: Theme.of(context).textTheme.titleLarge),
                  Text(dateFormat.format(dateTime)),
                  Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: List<Widget>.generate(masses[dayOffset].length,
                              (index) {
                            return TimeChip(time: masses[dayOffset][index].time);
                          })),
                ],
              ),
            ),
          ),
        );
    }
  }

  Widget _mapCard()
  {
    return Container(
      color: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                Text("Megközelítés",
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              Stack(
                  alignment: Alignment.center,
                  children: [
                Image.network(_getStaticMapUrl(800, 600)),
                Column(
                  children: [
                    Image.asset("assets/images/map_pin.png", width: 37, height: 57),
                    SizedBox(width: 37, height: 57),
                  ],
                )
              ]),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(HtmlUnescape().convert(widget.church.gettingThere ?? "")),
              ),
              Container(height: 1, color: Colors.black12,),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("ÚTVONAL", style: Theme.of(context).textTheme.titleMedium!.apply(color: Color.fromARGB(255, 255, 140, 0))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorBuilder(
      BuildContext context, Object error, StackTrace? stackTrace) {
    return Image.asset('assets/images/church_blurred.png', fit: BoxFit.cover);
  }

  Future<void> _toggleFavorites() async {
    Provider.of<FavoritesService>(context, listen: false).toggle(widget.church.id);
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  Future<void> loadMasses() async {
    MiserendDatabase db = await MiserendDatabase.create();
    var allMasses = await db.getMassesForChurch(widget.church.id);
    var massList = <List<Mass>>[];
    for (int i = 0; i < 20; ++i)
    {
       massList.add(getMassesForDayFromNow(allMasses, i));
    }
    setState(() {
      masses = massList;
    });
  }



  String _getStaticMapUrl(int width, int height)
    => "https://maps.googleapis.com/maps/api/staticmap?center=${widget.church.lat},${widget.church.lon}&zoom=17&size=${width}x$height&scale=2&key=AIzaSyD7gu93yYTqPpJ2G5K79AhBs1UoyGNIs_o";

  List<Mass> getMassesForDayFromNow(List<Mass> allMasses, int offsetInDays)
  {
    return MassFilter.filterMassListForDay(
        allMasses, DateTime.now().add(Duration(days: offsetInDays)));
  }
}
