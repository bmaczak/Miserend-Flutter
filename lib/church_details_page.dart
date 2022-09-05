import 'package:flutter/material.dart';
import 'package:miserend/database/favorites_service.dart';
import 'package:provider/provider.dart';

import 'database/church.dart';

class ChurchDetailsPage extends StatefulWidget {
  const ChurchDetailsPage({super.key, required this.church});

  final Church church;

  @override
  State<ChurchDetailsPage> createState() => _ChurchDetailsPageState();
}

class _ChurchDetailsPageState extends State<ChurchDetailsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(widget.church.name ?? ""),
        ),
        body: Center(
          child: Center(
            child: Text(widget.church.name ?? ""),),
        ),
    );
  }

  Future<void> _toggleFavorites(int churchId) async {
    Provider.of<FavoritesService>(context, listen: false).toggle(churchId);
  }
}
