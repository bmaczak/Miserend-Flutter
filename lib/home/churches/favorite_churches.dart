import 'package:flutter/material.dart';
import 'package:miserend/database/church_with_masses.dart';
import 'package:miserend/database/favorites_service.dart';
import 'package:miserend/database/miserend_database.dart';
import 'package:miserend/home/churches/church_list_item.dart';

import 'package:provider/provider.dart';

class FavoriteChurchesPage extends StatefulWidget {
  const FavoriteChurchesPage({super.key});

  @override
  State<FavoriteChurchesPage> createState() => _FavoriteChurchesPageState();
}

class _FavoriteChurchesPageState extends State<FavoriteChurchesPage>
    with AutomaticKeepAliveClientMixin<FavoriteChurchesPage> {

  List<ChurchWithMasses> churches = <ChurchWithMasses>[];

  late FavoritesService favoritesService;

  @override
  void initState() {
    super.initState();
    favoritesService = Provider.of<FavoritesService>(context, listen: false);
    favoritesService.addListener(() => mounted ? loadChurches() : null);
    loadChurches();
  }

  @override
  void dispose() {
    favoritesService.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black12,
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: favoritesService.favorites.length,
            itemBuilder: (BuildContext context, int index) {
              return ChurchListItem(
                  churchWithMasses: churches[index]
              );
            },
          )
        );
  }

  Future<void> loadChurches() async {
    MiserendDatabase db = await MiserendDatabase.create();
    var list = await db.getChurches(favoritesService.favorites.map((e) => e.churchId).toList());
    setState(() {
      churches = list;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
