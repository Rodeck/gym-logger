import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/auth/login.dart';
import 'package:mobile/auth/sign-in.dart';

class UnauthorizedBar extends AppBar {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("My app."),
      actions: [],
    );
  }
}
