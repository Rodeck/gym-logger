import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/models/gym_location.dart';
import 'package:mobile/models/location.dart';
import 'package:mobile/services/location.dart';
import 'package:mobile/storage/location-storage.dart';
import 'package:rxdart/rxdart.dart';

class GymsMap extends StatefulWidget {
  final List<GymLocation> gyms;

  const GymsMap({required this.gyms}) : super();

  @override
  State<StatefulWidget> createState() => _MapState();
}

class _MapState extends State<GymsMap> {
  GoogleMapController? _controller;
  late BehaviorSubject<Position?> positionStream;
  StreamSubscription? _locationStream;
  final LocationService _locationService = LocationService();
  List<Marker> gymMarkers = [];

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
  }

  Future<bool> _sendPosition(double latitude, double longitude) {
    return _locationService.sendLocation(latitude, longitude);
  }

  Future<void> _showGymPanel(GymLocation gym) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(gym.name),
            actions: [
              IconButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                icon: const Icon(Icons.delete),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'OK');
                },
                child: const Text('Ok'),
              )
            ],
          );
        });
  }

  _buildMarkers() {
    gymMarkers = widget.gyms
        .map((gym) => Marker(
            infoWindow: InfoWindow(
              title: gym.name,
            ),
            onTap: () async => await _showGymPanel(gym),
            markerId: MarkerId(gym.name),
            position: LatLng(gym.lattitude, gym.longitude)))
        .toList();
  }

  @override
  void dispose() async {
    if (_locationStream != null) {
      _locationStream!.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _buildMarkers();
    var storage = GetIt.instance<LocationStorage>();

    positionStream = storage.locationStream;
    var defaultZoom = 15;

    _locationStream = storage.locationStream
        .doOnData((location) async {
          if (_controller != null) {
            var zoom = await _controller!.getZoomLevel();
            _controller!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(location.latitude, location.longitude),
                    zoom: zoom),
              ),
            );
          }
        })
        .debounceTime(const Duration(seconds: 3))
        .listen((location) async {
          if (!await _sendPosition(location.latitude, location.longitude)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('There was an error during uploading location')),
            );
          }
        });
  }

  _buildMap(Position? position) {
    if (position != null) {
      var coords = LatLng(position.latitude, position.longitude);

      return GoogleMap(
        markers: gymMarkers.toSet(),
        initialCameraPosition: CameraPosition(target: coords, zoom: 15),
        onMapCreated: _onMapCreated,
        myLocationButtonEnabled: true,
      );
    }

    return const CircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: positionStream,
        builder: (BuildContext context, AsyncSnapshot<Position?> snapshot) {
          return SizedBox(
              width: MediaQuery.of(context)
                  .size
                  .width, // or use fixed size like 200
              height: MediaQuery.of(context).size.height - 56,
              child: _buildMap(snapshot.data));
        });
  }
}
