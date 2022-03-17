import 'package:mobile/models/user.dart';
import 'package:rxdart/rxdart.dart';

class UserStorage {
  BehaviorSubject<User?> userSubject = BehaviorSubject.seeded(null);
  BehaviorSubject<String?> tokenSubject = BehaviorSubject.seeded("");

  ValueStream<User?> getStream() => userSubject.stream;
  String? getToken() => tokenSubject.value;
  User? getUser() => userSubject.value;

  setUser(User? user) => userSubject.add(user);

  setToken(String token) => tokenSubject.add(token);

  clear() {
    userSubject.add(null);
    tokenSubject.add(null);
  }
}
