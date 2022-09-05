import 'package:flutter/material.dart';
import 'package:miserend/church_details_page.dart';
import 'package:miserend/database/favorites_service.dart';
import 'package:provider/provider.dart';

import 'database/church.dart';

class ChurchListItem extends StatefulWidget {
  const ChurchListItem({super.key, required this.church});

  final Church church;

  @override
  State<ChurchListItem> createState() => _ChurchListItemState();
}

class _ChurchListItemState extends State<ChurchListItem> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            _openDetails(widget.church, context);
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
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 8.0, 8.0, 4.0),
                                child: Text(widget.church.name ?? "",
                                    style:
                                    Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle1),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      8.0, 0.0, 8.0, 8.0),
                                  child: Text(widget.church.commonName ?? "",
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .subtitle2),
                                ),
                              ),
                              Container(color: Colors.grey, height: 1),
                              Consumer<FavoritesService>(
                                builder: (context, favoritesService, child) {
                                  return IconButton(
                                    icon: favoritesService
                                        .isFavorite(widget.church.id)
                                        ? const Icon(Icons.favorite)
                                        : const Icon(Icons.favorite_border),
                                    color: Colors.grey,
                                    tooltip: 'Toggle favorite',
                                    onPressed: () {
                                      setState(() {
                                        _toggleFavorites(widget.church.id);
                                      });
                                    },
                                  );
                                },
                              ),
                            ])),
                    Expanded(
                      flex: 1,
                      child: widget.church.imageUrl?.isNotEmpty ?? false
                          ? FadeInImage.assetNetwork(
                        image: widget.church.imageUrl ?? "",
                        fit: BoxFit.cover,
                        placeholder: 'assets/images/church_blurred.png',
                        imageErrorBuilder: _errorBuilder,
                      )
                          : Image.asset('assets/images/church_blurred.png',
                          fit: BoxFit.cover),
                    ),
                  ])),
        ),
      ),
    );
  }

  Future<void> _toggleFavorites(int churchId) async {
    Provider.of<FavoritesService>(context, listen: false).toggle(churchId);
  }

  _openDetails(Church church, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChurchDetailsPage(church: church)),
    );
  }

  Widget _errorBuilder(BuildContext context, Object error,
      StackTrace? stackTrace) {
    return Image.asset(
        'assets/images/church_blurred.png',
        fit: BoxFit.cover);
  }
}
