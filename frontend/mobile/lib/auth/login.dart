import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:mobile/auth/sign-in.dart';
import 'package:mobile/launch-screen/launch.dart';
import 'package:mobile/services/auth_service.dart';

import 'form_input_field.dart';
import 'google_button.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _service = AuthService();

  Future<FirebaseAuth> _initializeFirebase() async {
    FirebaseAuth firebaseApp = FirebaseAuth.instance;
    return firebaseApp;
  }

  _login(BuildContext context) async {
    var result =
        await _service.login(_emailController.text, _passwordController.text);

    if (result.success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Launch()),
        (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.message!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                              child: const Image(
                                  width: 100,
                                  height: 100,
                                  image: AssetImage('assets/images/logo.png')),
                            ),
                            const Text('Login', style: TextStyle(fontSize: 25)),
                            FormInput('Email', 'Enter email', _emailController),
                            FormInput(
                              'Password',
                              'Enter password',
                              _passwordController,
                              isPassword: true,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                // Validate returns true if the form is valid, or false otherwise.
                                if (_formKey.currentState!.validate()) {
                                  // If the form is valid, display a snackbar. In the real world,
                                  // you'd often call a server or save the information in a database.
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Processing Data')),
                                  );
                                  await _login(context);
                                }
                              },
                              child: const Text('Submit'),
                            ),
                            Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: GoogleSignInButton()),
                            TextButton(
                              onPressed: () => Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignInPage()),
                                  (Route<dynamic> route) => false),
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: const Text("Create new account"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
