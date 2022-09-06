import 'package:flutter/material.dart';

extension TimeOfDayConverter on TimeOfDay {
  String to24hours() {
    final h = hour.toString().padLeft(2, "0");
    final m = minute.toString().padLeft(2, "0");
    return "$h:$m";
  }
}