import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:miserend/LocationProvider.dart';
import 'package:miserend/database/MassWithChurch.dart';
import 'package:miserend/mass_list_item.dart';

import 'database/mass.dart';
import 'database/miserend_database.dart';
import 'mass_filter.dart';

class NearMassesPage extends StatefulWidget {
  const NearMassesPage({super.key});

  @override
  State<NearMassesPage> createState() => _NearMassesPageState();
}

class _NearMassesPageState extends State<NearMassesPage>  with
    AutomaticKeepAliveClientMixin<NearMassesPage>{

  late Position _currentPosition;
  List<MassWithChurch> masses = <MassWithChurch>[];

  @override
  void initState() {
    super.initState();
    loadMasses();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: masses.length,
      itemBuilder: (BuildContext context, int index) {
        return MassListItem(
            massWithChurch: masses[index]
        );
      },
    );
  }

  Future<void> loadMasses() async {
    MiserendDatabase db = await MiserendDatabase.create();
    Position position = await LocationProvider.getPosition();
    var list = await db.getCloseMasses(position.latitude, position.longitude);
    list = MassFilter.filterMassWithChurchListForDay(list, DateTime.now());
    setState(() {
      masses = list;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
