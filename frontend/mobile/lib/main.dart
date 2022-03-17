import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/auth/login.dart';
import 'package:mobile/auth/sign-in.dart';
import 'package:mobile/home.dart';
import 'package:mobile/launch-screen/launch.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/services/geolocation.dart';
import 'package:mobile/services/location.dart';
import 'package:mobile/storage/location-storage.dart';
import 'package:mobile/storage/visits-storage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/storage/user-storage.dart';
import 'firebase_options.dart';

void _reuestPermission(PermissionWithService permission) async {
  var permissionStatus = await permission.isGranted;
  if (!permissionStatus) {
    PermissionStatus? locationRequestResult =
        await Permission.location.request();

    if (locationRequestResult != PermissionStatus.granted) {
      return;
    }
  }
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var getIt = GetIt.instance;
  getIt.registerSingleton(UserStorage());
  getIt.registerSingleton(VisitsStorage());
  getIt.registerSingleton(LocationStorage());

  // You can request multiple permissions at once.
  var requiredPermissions = [Permission.location, Permission.locationAlways];

  for (var element in requiredPermissions) {
    _reuestPermission(element);
  }

  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    Geoservice().initialize();
    LocationService().initialize();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const Launch(),
      initialRoute: '/',
      routes: {
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/login': (context) => LoginPage(),
        '/signin': (context) => SignInPage(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
