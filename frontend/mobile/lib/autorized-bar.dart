import 'package:flutter/material.dart';
import 'package:mobile/launch-screen/launch.dart';
import 'package:mobile/profile.dart';
import 'package:mobile/storage.dart';

class AuthorizedAppBar extends StatelessWidget {
  const AuthorizedAppBar({Key? key}) : super(key: key);

  void _navigate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfleScreen()),
    );
  }

  Future _logout(BuildContext context) async {
    var storage = SecureStorage();

    await storage.deleteToken();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Launch()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      color: Colors.blue,
      itemBuilder: (context) => [
        const PopupMenuItem<String>(value: "logout", child: Icon(Icons.logout)),
        const PopupMenuItem<String>(
            value: "profile", child: Icon(Icons.account_box)),
      ],
      onSelected: (String item) async => {
        if (item == "logout") {await _logout(context)} else {_navigate(context)}
      },
    );
  }
}
