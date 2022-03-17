import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'form_input_field.dart';
import 'google_button.dart';
import 'login.dart';

class SignInPage extends StatelessWidget {
  Future<FirebaseAuth> _initializeFirebase() async {
    FirebaseAuth firebaseApp = FirebaseAuth.instance;
    return firebaseApp;
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _register(BuildContext context) async {
    var auth = await _initializeFirebase();
    final User? user = (await auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ))
        .user;

    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } else {
      const snackBar = SnackBar(
        content: Text('Something went wrong...'),
      );

      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                            const Text('Create new account',
                                style: TextStyle(fontSize: 25)),
                            FormInput('Email', 'Enter email', _emailController),
                            FormInput(
                              'Password',
                              'Enter password',
                              _passwordController,
                              isPassword: true,
                            ),
                            Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: GoogleSignInButton()),
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
                                  _register(context);
                                }
                              },
                              child: const Text('Submit'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                  (Route<dynamic> route) => false),
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: const Text(
                                    "Already have an account? Login first."),
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
