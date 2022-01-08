import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'models/user.dart';

class SecureStorage {
  static SecureStorage? _instance;

  factory SecureStorage() =>
      _instance ?? SecureStorage._(const FlutterSecureStorage());

  SecureStorage._(this._storage);

  final FlutterSecureStorage _storage;
  static const _tokenKey = 'SESSION_TOKEN';
  static const _userKey = 'USER';

  Future<void> persistToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<bool> hasToken() async {
    var value = await _storage.read(key: _tokenKey);
    return value != null;
  }

  Future<void> deleteToken() async {
    return _storage.delete(key: _tokenKey);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future persistUser(String? email, String? id) async {
    if (email != null && id != null) {
      return _storage.write(key: _userKey, value: jsonEncode(User(email, id)));
    }
  }

  Future<User?> readUser() async {
    var user = await _storage.read(key: _userKey);

    if (user != null) {
      var map = jsonDecode(user);
      return User.fromJson(map);
    }

    return null;
  }
}
