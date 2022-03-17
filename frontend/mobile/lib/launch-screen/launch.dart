import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/auth/login.dart';
import 'package:mobile/auth/sign-in.dart';
import 'package:mobile/home.dart';
import 'package:mobile/storage/user-storage.dart';
import 'package:mobile/visits/visits.dart';

import '../profile.dart';
import '../unauthorized-bar.dart';

class Launch extends StatefulWidget {
  const Launch({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LaunchState();
}

class _LaunchState extends State<Launch> {
  int _currentIndex = 0;

  void navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var userStorage = GetIt.instance<UserStorage>();
    var token = userStorage.getToken();
    if (token == null || token == '') {
      Future.microtask(() => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false));
    }

    var children = [
      VisitsScreen(),
      const HomeScreen(),
      ProfleScreen(),
    ];

    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Visits',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profle',
              ),
            ]),
        body: children[_currentIndex]);
  }
}
