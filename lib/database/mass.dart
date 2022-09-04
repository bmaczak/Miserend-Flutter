class Mass {
  final int id;
  final int churchId;
  final int day;
  final String? time;
  final String? season;
  final String? language;
  final String? tags;
  final String? period;
  final int? weight;
  final int? startDate;
  final int? endDate;
  final String? comment;

  Mass({
      required this.id,
      required this.churchId,
      required this.day,
      required this.time,
      required this.season,
      required this.language,
      required this.tags,
      required this.period,
      required this.weight,
      required this.startDate,
      required this.endDate,
      required this.comment
  });
}
