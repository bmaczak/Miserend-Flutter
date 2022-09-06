import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'extentions.dart';

class TimeChip extends StatelessWidget {
  const TimeChip({super.key, required this.time});

  final TimeOfDay? time;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
          color: const Color.fromARGB(255, 255, 140, 0),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(time?.to24hours() ?? "?"),
          )),
    );
  }
}
