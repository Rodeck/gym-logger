import 'package:flutter/material.dart';
import 'package:mobile/auth/login.dart';
import 'package:mobile/auth/sign-in.dart';

import '../unauthorized-bar.dart';

class Launch extends StatelessWidget {
  const Launch({Key? key}) : super(key: key);

  void navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    var actions = [
      IconButton(
          onPressed: () => navigate(context, LoginPage()),
          icon: const Icon(Icons.login)),
      IconButton(
          onPressed: () => navigate(context, SignInPage()),
          icon: const Icon(Icons.create_outlined))
    ];

    return Scaffold(
        appBar: AppBar(actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            color: Colors.blue,
            itemBuilder: (context) => [
              PopupMenuItem<Widget>(
                  value: LoginPage(), child: const Icon(Icons.login)),
              PopupMenuItem<Widget>(
                  value: SignInPage(), child: const Icon(Icons.account_box)),
            ],
            onSelected: (Widget item) => {navigate(context, item)},
          )
        ]),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Welcome, please login first."),
            ],
          ),
        ));
  }
}
