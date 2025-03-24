import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:miserend/database/church.dart';
import 'package:miserend/database/church_with_masses.dart';
import 'package:miserend/database/miserend_database.dart';
import 'package:miserend/home/churches/church_list_item.dart';
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
  final Map<String, Marker> _markers = {};
  late BitmapDescriptor customIcon;
  late ui.Image markerImage;
  late Color clusterColor;
  ChurchWithMasses? selectedChurch;

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)), 'assets/images/map_pin.png')
        .then((onValue) {
      customIcon = onValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [GoogleMap(
          initialCameraPosition: initialPosition,
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          markers: _markers.values.toSet(),
          onMapCreated: _onMapCreated),
        selectedChurch != null ? Column(
          children: [
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ChurchListItem(churchWithMasses: selectedChurch!),
            ),
          ],
        ) : Container()
      ]
    );
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    markerImage = await loadImage('map_pin.png');
    MiserendDatabase database = await MiserendDatabase.create();
    final churches = await database.getAllChurches();
    _setDefaultPosition();
    setState(() {
      _markers.clear();
      for (final church in churches) {
        final marker = Marker(
          markerId: MarkerId(church.id.toString()),
          position: church.location,
          onTap: () {
            _onTapped(church);
          },
        );
        _markers[church.id.toString()] = marker;
      }
    });
  }

  Future<void> _setDefaultPosition() async {
    final GoogleMapController controller = await _controller.future;
    Position position = await LocationProvider.getPosition();
    controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 14)));
  }


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

  _onTapped(Church church) {
     _showChurchCard(church);
  }

  Future<void> _showChurchCard(Church church) async {
    ChurchWithMasses churchWithMasses = (await (await MiserendDatabase.create()).getChurches(<int>[church.id])).first;
    setState(() {
      selectedChurch = churchWithMasses;
    });
  }

}
