import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:mobile/models/location.dart';
import 'package:mobile/services/location.dart';
import 'package:mobile/storage/location-storage.dart';
import 'package:rxdart/rxdart.dart';
import 'package:location/location.dart';

class Geoservice {
  BehaviorSubject<DateTime> locate = BehaviorSubject();
  LocationService service = LocationService();
  final _storage = GetIt.instance<LocationStorage>();
  Location location = Location();
  late StreamSubscription _streamSubscription;

  static final Geoservice _singleton = Geoservice._internal();

  factory Geoservice() {
    return _singleton;
  }

  Geoservice._internal();

  initialize() async {
    location.enableBackgroundMode(enable: true);
    _streamSubscription = location.onLocationChanged
        //.debounceTime(const Duration(seconds: 3))
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        print("Location received, adding to storage. ${DateTime.now()}");
        _storage.set(Position(currentLocation.latitude!,
            currentLocation.longitude!, DateTime.now()));
      }
    });
  }

  Future<Position> getCurrentPosition() async {
    var currentPosition = await location.getLocation();

    return Position(
        currentPosition.latitude!, currentPosition.longitude!, DateTime.now());
  }
}
