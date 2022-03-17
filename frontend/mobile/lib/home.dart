import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/services/geolocation.dart';
import 'package:mobile/services/location.dart';

import 'map/map.dart';
import 'models/gym_location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _gymNameController = TextEditingController();
  final LocationService _locationService = LocationService();

  _sendGym() async {
    var name = _gymNameController.value.text;
    Geoservice().getCurrentPosition().then((value) =>
        _locationService.sendNewGym(value.latitude, value.longitude, name));
  }

  Future<List<GymLocation>> _getNearbyGyms() async {
    var currenPosition = await Geoservice().getCurrentPosition();
    return _locationService.getNearbyGyms(
        currenPosition.latitude, currenPosition.longitude);
  }

  Future<void> _toggleDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Provide gym name."),
            content: TextField(
              controller: _gymNameController,
              decoration: const InputDecoration(hintText: "Gym name"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _sendGym();
                  _gymNameController.clear();
                  Navigator.pop(context, 'OK');
                },
                child: const Text('Send'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 85,
            child: FutureBuilder(
                future: _getNearbyGyms(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<GymLocation>> snapshot) {
                  if (snapshot.hasData) {
                    return Stack(children: [
                      GymsMap(gyms: snapshot.data!),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.fromLTRB(15, 0, 0, 40),
                        child: FloatingActionButton(
                          child: const Icon(Icons.add),
                          onPressed: _toggleDialog,
                        ),
                      ),
                    ]);
                  } else {
                    return Center(
                        child: Container(
                      margin: const EdgeInsets.only(top: 200),
                      child: Column(
                        children: const [
                          CircularProgressIndicator(),
                          Text("Loading map."),
                        ],
                      ),
                    ));
                  }
                }),
          )
        ],
      ),
    );
  }
}
