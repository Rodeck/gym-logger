import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/storage/user-storage.dart';

import 'models/user.dart';

class ProfleScreen extends StatelessWidget {
  ProfleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var stream = GetIt.instance<UserStorage>().getStream();
    return SafeArea(
      child: StreamBuilder(
          stream: stream,
          builder: (context, AsyncSnapshot<User?> state) => Column(
                children: [
                  Center(
                      child: !state.hasData
                          ? const Text("User not found, login first")
                          : UserInfo())
                ],
              )),
    );
  }
}

class UserInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 100,
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width - 50,
            height: MediaQuery.of(context).size.height - 450,
            child: Card()),
        ProfleGlobalActions(),
      ],
    );
  }
}

class ProfleGlobalActions extends StatelessWidget {
  void _removeAccount() {}

  void _logout(BuildContext context) {
    AuthService().logout(context);
  }

  List<Widget> _buildActions(BuildContext context) {
    List<Widget> actions = [
      ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.white, //change background color of button
            onPrimary: Colors.black, //change text color of button
            elevation: 15.0,
          ),
          onPressed: () => _logout(context),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout),
              const Text(
                "Logout",
              ),
            ],
          )),
      ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
          ),
          onPressed: () => _removeAccount(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delete),
              const Text(
                "Remove account",
              ),
            ],
          ))
    ];

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width - 50,
        height: 300 - 150,
        child: ListView(
          padding: const EdgeInsets.all(10),
          scrollDirection: Axis.vertical,
          children: _buildActions(context),
        ));
  }
}
