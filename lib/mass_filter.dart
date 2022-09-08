import 'package:miserend/database/mass_with_church.dart';

import 'database/mass.dart';

class MassFilter {

  static List<Mass> filterMassListForDay(List<Mass> masses, DateTime day) => masses.where((m) => isMassOnDay(m, day)).toList();

  static List<MassWithChurch> filterMassWithChurchListForDay(List<MassWithChurch> masses, DateTime day) => masses.where((m) => isMassOnDay(m.mass, day)).toList();

  static bool isMassOnDay(Mass mass, DateTime day) {
    return isOnSameDayOfTheWeek(mass, day) && dateRangeCorrect(mass, day);
  }

  static bool isOnSameDayOfTheWeek(Mass mass, DateTime day) => mass.day == day.weekday || mass.day == 0;

  static bool dateRangeCorrect(Mass mass, DateTime day) {
    int startDate = mass.startDate ?? 0;
    int endDate = mass.endDate ?? 0;
    int dayInDatabaseFormat = (day.month) * 100 + day.day;
    if (startDate < endDate) {
      return startDate <= dayInDatabaseFormat && dayInDatabaseFormat <= endDate;
    } else if (startDate > endDate){
      return startDate <= dayInDatabaseFormat || dayInDatabaseFormat <= endDate;
    } else {
      return startDate == dayInDatabaseFormat && dayInDatabaseFormat == endDate;
    }
  }
}