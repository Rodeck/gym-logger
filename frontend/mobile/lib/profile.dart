import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/storage/user-storage.dart';

import 'autorized-bar.dart';
import 'models/user.dart';

class ProfleScreen extends StatelessWidget {
  ProfleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var stream = GetIt.instance<UserStorage>().getStream();
    return Scaffold(
      appBar: AppBar(
        actions: [AuthorizedAppBar()],
      ),
      body: StreamBuilder(
          stream: stream,
          builder: (context, AsyncSnapshot<User?> state) => Column(
                children: [
                  Center(
                      child: !state.hasData
                          ? const Text("User not found, login first")
                          : Text(state.data!.email))
                ],
              )),
    );
  }
}
