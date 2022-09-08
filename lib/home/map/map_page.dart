import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:miserend/database/church.dart';
import 'package:miserend/database/miserend_database.dart';
import 'package:miserend/location_provider.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(47.2537659, 19.752314),
    zoom: 8,
  );

  final Completer<GoogleMapController> _controller = Completer();
  late ClusterManager _manager;
  Set<Marker> markers = {};
  late BitmapDescriptor customIcon;
  late ui.Image markerImage;
  late Color clusterColor;

  @override
  void initState() {
    super.initState();
    _manager = ClusterManager<Church>({}, _updateMarkers,
        markerBuilder: _markerBuilder);
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)), 'assets/images/map_pin.png')
        .then((onValue) {
      customIcon = onValue;
    });
    _loadMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        initialCameraPosition: initialPosition,
        mapType: MapType.normal,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        markers: markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _manager.setMapId(controller.mapId);
        },
        onCameraMove: _manager.onCameraMove,
        onCameraIdle: _manager.updateMap);
  }

  Future<void> _loadMarkers() async {
    markerImage = await loadImage('map_pin.png');
    final GoogleMapController controller = await _controller.future;
    Position position = await LocationProvider.getPosition();
    controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 14)));
    MiserendDatabase database = await MiserendDatabase.create();
    _manager.setItems(await database.getAllChurches());
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      this.markers = markers;
    });
  }

  Future<Marker> Function(Cluster<Church>) get _markerBuilder =>
      (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {},
          icon: cluster.isMultiple ? await _getMarkerBitmap(125,
              text:  cluster.count.toString()) : customIcon,
        );
      };

  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Theme.of(context).primaryColor;
    final Paint paint2 = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  Future<ui.Image> loadImage(String imageName) async {
    final data = await rootBundle.load('assets/images/$imageName');
    return decodeImageFromList(data.buffer.asUint8List());
  }
}
