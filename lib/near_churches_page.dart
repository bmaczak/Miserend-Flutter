import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:miserend/LocationProvider.dart';
import 'package:miserend/church_list_item.dart';

import 'database/church.dart';
import 'database/miserend_database.dart';

class NearChurchesPage extends StatefulWidget {
  const NearChurchesPage({super.key});

  @override
  State<NearChurchesPage> createState() => _NearChurchesPageState();
}

class _NearChurchesPageState extends State<NearChurchesPage>  with
    AutomaticKeepAliveClientMixin<NearChurchesPage>{

  late Position _currentPosition;
  List<Church> churches = <Church>[];

  @override
  void initState() {
    super.initState();
    loadChurches();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: churches.length,
        itemBuilder: (BuildContext context, int index) {
          return ChurchListItem(
              church: churches[index]
          );
        },
    );
  }

  Future<void> loadChurches() async {
    MiserendDatabase db = await MiserendDatabase.create();
    Position position = await LocationProvider.getPosition();
    var list = await db.getCloseChurches(position.latitude, position.longitude);
    setState(() {
      churches = list;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
