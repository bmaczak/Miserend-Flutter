class Church {
  final int id;
  final String? name;
  final String? commonName;
  final bool? isGreek;
  final double? lat;
  final double? lon;
  final String? address;
  final String? city;
  final String? country;
  final String? county;
  final String? street;
  final String? gettingThere;
  final String? imageUrl;

  const Church({
    required this.id,
    required this.name,
    required this.commonName,
    required this.isGreek,
    required this.lat,
    required this.lon,
    required this.address,
    required this.city,
    required this.country,
    required this.county,
    required this.street,
    required this.gettingThere,
    required this.imageUrl
  });
}