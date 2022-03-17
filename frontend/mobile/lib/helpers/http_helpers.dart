import 'dart:io';

import 'package:http/http.dart';
import 'package:logger/logger.dart';

class HttpHelpers {
  static final Logger _logger = Logger();

  static bool isSuccess(Response response, String url) {
    _handleResponse(response, url);
    var isSuccess = _isSuccess(response.statusCode);

    return isSuccess;
  }

  static _handleResponse(Response response, String url) {
    if (_isSuccess(response.statusCode)) {
      _logger.d("Http call for address $url succeded.");
    } else {
      _logger.w(
          "Http call for address $url failed. Status code: ${response.statusCode}, response: $response");
    }
  }

  static bool _isSuccess(int statusCode) =>
      statusCode < 300 && statusCode >= 200;
}
