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
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
                                child: Text(widget.church.name ?? "",
                                    style: Theme.of(context).textTheme.subtitle1),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                                  child: Text(widget.church.commonName ?? "",
                                      style: Theme.of(context).textTheme.subtitle2),
                                ),
                              ),
                              Container(color: Colors.grey, height: 1),
                              IconButton(
                                icon: const Icon(Icons.favorite_border),
                                color: Colors.grey,
                                tooltip: 'Toggle favorite',
                                onPressed: () {
                                  setState(() {
                                    _toggleFavorites();
                                  });
                                },
                              ),
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

  _toggleFavorites() {

  }
}
