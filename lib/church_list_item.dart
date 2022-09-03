import 'package:flutter/material.dart';

import 'database/church.dart';

class ChurchListItem extends StatefulWidget {
  const ChurchListItem({super.key, required this.church});

  final Church church;

  @override
  State<ChurchListItem> createState() => _ChurchListItemState();
}

class _ChurchListItemState extends State<ChurchListItem> {
  _ChurchListItemState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            debugPrint('Card tapped.');
          },
          child: SizedBox(
            height: 100,
            child: Row(
              children: [
                Image.network(widget.church.imageUrl ?? ""),
                Center(child: Text(widget.church.name ?? "")),
              ]
            )
          ),
        ),
      ),
    );
  }
}
