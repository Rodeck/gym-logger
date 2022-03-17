import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/helpers/http_helpers.dart';
import 'package:mobile/models/gym_location.dart';
import 'package:mobile/storage/location-storage.dart';
import 'package:mobile/storage/user-storage.dart';
import 'package:get_it/get_it.dart';

class LocationService {
  static final LocationService _singleton = LocationService._internal();

  factory LocationService() {
    return _singleton;
  }

  LocationService._internal();

  DateTime _lastSendDate = DateTime.now();

  initialize() {
    var storage = GetIt.instance<LocationStorage>();
    storage.getStream().where((element) {
      var diff = DateTime.now().difference(_lastSendDate);
      return diff.inSeconds > 10;
    }).listen((location) async {
      print("Location recived for sending, ${DateTime.now()}");
      _lastSendDate = DateTime.now();
      await sendLocation(location.latitude, location.longitude);
    });
  }

  Future<bool> removeVisit(String id) {
    var token = GetIt.instance<UserStorage>().getToken();
    var user = GetIt.instance<UserStorage>().getUser();

    if (token == null || user == null) {
      return Future.value(false);
    }

    var backendUrl = dotenv.env['LOCATION_BACKEND'];
    var url = "$backendUrl/$id";

    return http.delete(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token,
      },
    ).then((response) => HttpHelpers.isSuccess(response, url));
  }

  Future<bool> sendLocation(double latitude, double longitude) {
    var token = GetIt.instance<UserStorage>().getToken();
    var user = GetIt.instance<UserStorage>().getUser();

    if (token == null || user == null) {
      return Future.value(false);
    }

    var backendUrl = dotenv.env['LOCATION_BACKEND'];
    var url = "$backendUrl/";

    return http
        .post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token,
          },
          body: jsonEncode(<String, String>{
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'date': DateTime.now().toString(),
          }),
        )
        .then((response) => HttpHelpers.isSuccess(response, url));
  }

  Future<bool> sendNewGym(double latitude, double longitude, String name) {
    var token = GetIt.instance<UserStorage>().getToken();
    var user = GetIt.instance<UserStorage>().getUser();

    if (token == null || user == null) {
      return Future.value(false);
    }

    var backendUrl = dotenv.env['GYMS_BACKEND'];
    var url = "$backendUrl/";

    return http
        .post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token,
          },
          body: jsonEncode(<String, String>{
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'date': DateTime.now().toString(),
            'name': name,
          }),
        )
        .then((response) => HttpHelpers.isSuccess(response, url));
  }

  Future<List<GymLocation>> getNearbyGyms(double latitude, double longitude) {
    var token = GetIt.instance<UserStorage>().getToken();
    var user = GetIt.instance<UserStorage>().getUser();

    if (token == null || user == null) {
      return Future.error("User not authenticated.");
    }

    var backendUrl = dotenv.env['GYMS_BACKEND'];
    var url = "$backendUrl/nearby?latitude=$latitude&longitude=$longitude";

    return http.get(Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': token,
    }).then((response) {
      if (HttpHelpers.isSuccess(response, url)) {
        var result = GymLocation.parseGyms(response.body);
        return result;
      }

      throw Exception("Statuscode indicates failure ${response.statusCode}");
    });
  }
}
