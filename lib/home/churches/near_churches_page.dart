import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:miserend/database/church_with_masses.dart';
import 'package:miserend/database/miserend_database.dart';
import 'package:miserend/location_provider.dart';
import 'package:miserend/home/churches/church_list_item.dart';

class NearChurchesPage extends StatefulWidget {
  const NearChurchesPage({super.key});

  @override
  State<NearChurchesPage> createState() => _NearChurchesPageState();
}

class _NearChurchesPageState extends State<NearChurchesPage>  with
    AutomaticKeepAliveClientMixin<NearChurchesPage>{

  late Position _currentPosition;
  List<ChurchWithMasses> churches = <ChurchWithMasses>[];

  @override
  void initState() {
    super.initState();
    loadChurches();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.black12,
      child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: churches.length,
          itemBuilder: (BuildContext context, int index) {
            return ChurchListItem(
                churchWithMasses: churches[index]
            );
          },
      ),
    );
  }

  Future<void> loadChurches() async {
    MiserendDatabase db = await MiserendDatabase.create();
    Position position = await LocationProvider.getPosition();
    var list = await db.getCloseChurchesWithMasses(position.latitude, position.longitude);
    setState(() {
      churches = list;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
