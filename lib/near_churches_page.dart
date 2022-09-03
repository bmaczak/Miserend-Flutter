import 'package:flutter/material.dart';
import 'package:miserend/church_list_item.dart';

import 'database/church.dart';
import 'database/miserend_database.dart';

class NearChurchesPage extends StatefulWidget {
  const NearChurchesPage({super.key});

  @override
  State<NearChurchesPage> createState() => _NearChurchesPageState();
}

class _NearChurchesPageState extends State<NearChurchesPage> {

  List<Church> churches = <Church>[];

  @override
  void initState() {
    super.initState();
    loadChurches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Közeli templomok"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: churches.length,
        itemBuilder: (BuildContext context, int index) {
          return ChurchListItem(
              church: churches[index]
          );
        },
      ),
    );
  }

  Future<void> loadChurches() async {
    MiserendDatabase db = await MiserendDatabase.create();
    var list = await db.getAllChurches();
    setState(() {
      churches = list;
    });
  }
}
