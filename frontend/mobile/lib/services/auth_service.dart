import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as gAuth;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/helpers/http_helpers.dart';
import 'package:mobile/launch-screen/launch.dart';
import 'package:mobile/models/login-result.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/storage/user-storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  Future logout(BuildContext context) async {
    var storage = GetIt.instance<UserStorage>();

    storage.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Launch()),
      (Route<dynamic> route) => false,
    );
  }

  Future<bool> _createProfile(String email, String userId) {
    var token = GetIt.instance<UserStorage>().getToken();
    var user = GetIt.instance<UserStorage>().getUser();

    if (token == null || user == null) {
      return Future.value(false);
    }

    var backendUrl = dotenv.env['ACCOUNT_BACKEND'];
    var url = "$backendUrl/account";

    return http
        .post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token,
          },
          body: jsonEncode(
              <String, String>{'userId': user.id, 'email': user.email}),
        )
        .then((response) => HttpHelpers.isSuccess(response, url));
  }

  Future _setUser(gAuth.UserCredential userCredential) async {
    var storage = GetIt.instance<UserStorage>();
    storage
        .setUser(User(userCredential.user!.email!, userCredential.user!.uid));
    storage.setToken(await userCredential.user!.getIdToken());
  }

  Future<LoginResult> signInWithGoogle({required BuildContext context}) async {
    gAuth.FirebaseAuth auth = gAuth.FirebaseAuth.instance;
    gAuth.User? user;

    if (kIsWeb) {
      gAuth.GoogleAuthProvider authProvider = gAuth.GoogleAuthProvider();

      try {
        final gAuth.UserCredential userCredential =
            await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final gAuth.AuthCredential credential =
            gAuth.GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final gAuth.UserCredential userCredential =
              await auth.signInWithCredential(credential);

          user = userCredential.user;
          if (userCredential.user != null &&
              userCredential.user?.email != null) {
            await _setUser(userCredential);

            return LoginResult(success: true);
          }
        } on gAuth.FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            return LoginResult(
                success: false, message: 'Provided credentials are invalid.');
          } else if (e.code == 'invalid-credential') {
            return LoginResult(
                success: false, message: 'Provided credentials are invalid.');
          }
        } catch (e) {
          return LoginResult(
              success: false,
              message: 'Unknown error occurred, please try again.');
        }
      }
    }

    return LoginResult(
        success: false, message: 'Unknown error occurred, please try again.');
  }

  Future<LoginResult> login(String email, String password) async {
    try {
      gAuth.UserCredential userCredential = await gAuth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null && userCredential.user?.email != null) {
        await _setUser(userCredential);

        return Future.value(LoginResult(success: true));
      }

      return Future.value(LoginResult(success: false));
    } on gAuth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return Future.value(
            LoginResult(success: false, message: 'User not found.'));
      } else if (e.code == 'wrong-password') {
        return Future.value(
            LoginResult(success: false, message: 'Password incorrect'));
      }
    }

    return Future.value(LoginResult(success: false, message: 'Unknown error.'));
  }
}
