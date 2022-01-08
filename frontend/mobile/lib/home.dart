import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:mobile/services/location.dart';
import 'package:rxdart/rxdart.dart';

import 'autorized-bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final Location _location = Location();
  late GoogleMapController _controller;
  final LocationService _locationService = LocationService();
  double lastReadTime = 0;
  final double interval = 3.0;

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    _location.onLocationChanged
        .doOnData((location) {
          _controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(location.latitude!, location.longitude!),
                  zoom: 15),
            ),
          );
        })
        .debounceTime(const Duration(seconds: 3))
        .listen((location) async {
          if (!await _sendPosition(location.latitude!, location.longitude!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('There was an error during uploading location')),
            );
          }
        });
  }

  Future<bool> _sendPosition(double latitude, double longitude) {
    return _locationService.sendLocation(latitude, longitude);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [AuthorizedAppBar()],
      ),
      body: Column(
        children: [
          const Text("Home works."),
          FutureBuilder(
              future: _determinePosition(),
              builder:
                  (BuildContext context, AsyncSnapshot<Position> snapshot) {
                if (snapshot.hasData) {
                  return SizedBox(
                      width: MediaQuery.of(context)
                          .size
                          .width, // or use fixed size like 200
                      height: MediaQuery.of(context).size.height - 200,
                      child: GoogleMap(
                        initialCameraPosition: _kGooglePlex,
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: true,
                      ));
                } else {
                  return const CircularProgressIndicator();
                }
              })
        ],
      ),
    );
  }
}
