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
    placeholderBuilder(
        BuildContext context, Object exception, StackTrace? stackTrace) {
      return Image.asset(
        'assets/images/church_blurred.png',
        fit: BoxFit.cover,
      );
    }

    return Center(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            debugPrint('Card tapped.');
          },
          child: SizedBox(
              height: 176,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Column(children: [
                          Text(widget.church.name ?? ""),
                          Text(widget.church.commonName ?? ""),
                        ])),
                    Expanded(
                      flex: 1,
                      child: FadeInImage.assetNetwork(
                        image: widget.church.imageUrl ?? "",
                        fit: BoxFit.cover,
                        placeholder: 'assets/images/church_blurred.png',
                        imageErrorBuilder: placeholderBuilder,
                      ),
                    ),
                  ])),
        ),
      ),
    );
  }
}
