import 'package:flutter/material.dart';

import 'database/MassWithChurch.dart';
import 'database/mass.dart';

class MassListItem extends StatelessWidget {
  const MassListItem({super.key, required this.massWithChurch});

  final MassWithChurch massWithChurch;

  @override
  Widget build(BuildContext context) {
    placeholderBuilder(
        BuildContext context, Object exception, StackTrace? stackTrace) {
      return Image.asset(
        'assets/images/church_blurred.png',
        fit: BoxFit.cover,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: SizedBox(
              width: 72,
              height: 72,
              child: FadeInImage.assetNetwork(
                image: massWithChurch.church.imageUrl ?? "",
                fit: BoxFit.cover,
                placeholder: 'assets/images/church_blurred.png',
                imageErrorBuilder: placeholderBuilder,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(massWithChurch.church.name ?? "?"),
                Text(massWithChurch.mass.time ?? "?"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
