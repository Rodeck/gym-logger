import 'package:http/http.dart' as http hide BaseResponse;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/helpers/http_helpers.dart';
import 'package:mobile/models/visit.dart';
import 'package:mobile/models/base-response.dart';
import 'package:mobile/storage/user-storage.dart';
import 'package:get_it/get_it.dart';

class VisitsService {
  Future<BaseResponse<List<Visit>>> getLastVisits() {
    var token = GetIt.instance<UserStorage>().getToken();
    var user = GetIt.instance<UserStorage>().getUser();

    if (token == null || user == null) {
      return Future.value(BaseResponse<List<Visit>>(
          success: false, message: "User is not authenticated."));
    }

    var take = 20;
    var backendUrl = dotenv.env['LOCATION_BACKEND'];
    var url = "$backendUrl/last?take=$take";

    return http.get(Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': token,
    }).then((response) {
      if (HttpHelpers.isSuccess(response, url)) {
        var result = Visit.parseVisits(response.body);
        return BaseResponse<List<Visit>>(success: true, result: result);
      } else {
        var statusCode = response.statusCode;
        return BaseResponse<List<Visit>>(
            success: true,
            message: "There was an error, status code: $statusCode");
      }
    });
  }
}
