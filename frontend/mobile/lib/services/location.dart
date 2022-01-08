import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/storage/user-storage.dart';
import 'package:get_it/get_it.dart';

class LocationService {
  Future<bool> sendLocation(double latitude, double longitude) {
    var token = GetIt.instance<UserStorage>().getToken();
    var user = GetIt.instance<UserStorage>().getUser();

    if (token == null || user == null || user.id == null) {
      return Future.value(false);
    }

    var backendUrl = dotenv.env['BACKEND'];
    var url = "$backendUrl/location";

    return http
        .post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token,
          },
          body: jsonEncode(<String, String>{
            'latitude': latitude.toString(),
            'longitude': longitude.toString()
          }),
        )
        .then((response) => _isSuccess(response));
  }

  bool _isSuccess(Response response) =>
      response.statusCode >= 200 && response.statusCode < 300;
}
