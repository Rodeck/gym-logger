import 'package:mobile/models/location.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math';

class LocationStorage {
  late int id;

  LocationStorage() {
    Random rnd = Random();
    id = rnd.nextInt(1000);
  }

  BehaviorSubject<Position> locationStream = BehaviorSubject();

  ValueStream<Position> getStream() => locationStream.stream;

  set(Position location) => locationStream.add(location);
}
