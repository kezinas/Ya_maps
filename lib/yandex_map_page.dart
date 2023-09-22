import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:maps_example/screen.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class YandexMapPage extends StatefulWidget {
  const YandexMapPage({Key? key}) : super(key: key);

  @override
  State<YandexMapPage> createState() => _YandexMapPageState();
}

class _YandexMapPageState extends State<YandexMapPage> {
  final _location = Location();
  final List<MapObject> _mapObjects = [];
  late YandexMapController _controller;
  final MapObjectId _mapObjectId = const MapObjectId('raw_icon_placemark');
  late final Uint8List _placemarkIcon;
  late final Point p;
  late Point last;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yandex Map page"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          FloatingActionButton(onPressed: () {
            //final String a = (p.latitude.toString() + p.longitude.toString());
            points.add("${last.latitude} ${last.longitude}");
            Navigator.pop(context);
          }),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: YandexMap(
                mapObjects: _mapObjects,
                onMapCreated: _onMapCreated,
                onMapTap: _addMarker,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMapCreated(YandexMapController controller) {
    _controller = controller;
    _checkLocationPermission();
  }

  _checkLocationPermission() async {
    bool locationServiceEnabled = await _location.serviceEnabled();
    if (!locationServiceEnabled) {
      locationServiceEnabled = await _location.requestService();
      if (!locationServiceEnabled) {
        return;
      }
    }

    PermissionStatus locationForAppStatus = await _location.hasPermission();
    if (locationForAppStatus == PermissionStatus.denied) {
      await _location.requestPermission();
      locationForAppStatus = await _location.hasPermission();
      if (locationForAppStatus != PermissionStatus.granted) {
        return;
      }
    }
    LocationData locationData = await _location.getLocation();
    _placemarkIcon = await _rawPlacemarkImage();
    final point = Point(
        latitude: locationData.latitude!, longitude: locationData.longitude!);
    p = point;
    await _addMarker(point);
    await _controller.moveCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: point)));
  }

  Future _addMarker(Point point) async {
    _mapObjects.add(
      PlacemarkMapObject(
        mapId: _mapObjectId,
        point: point,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromBytes(_placemarkIcon),
          ),
        ),
      ),
    );
    setState(() {});
    last = point;
  }

  Future<Uint8List> _rawPlacemarkImage() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(50, 50);
    final fillPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const radius = 20.0;

    final circleOffset = Offset(size.height / 2, size.width / 2);

    canvas.drawCircle(circleOffset, radius, fillPaint);
    canvas.drawCircle(circleOffset, radius, strokePaint);

    final image = await recorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await image.toByteData(format: ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }
}
