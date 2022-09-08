import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Church with ClusterItem {
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

  Church({
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

  @override
  LatLng get location => (lat != null && lon != null) ? LatLng(lat!, lon!) : const LatLng(0, 0);
}