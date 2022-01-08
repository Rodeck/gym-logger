import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/auth/login.dart';
import 'package:mobile/auth/sign-in.dart';
import 'package:mobile/home.dart';
import 'package:mobile/launch-screen/launch.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/storage/user-storage.dart';
import 'firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // You can request multiple permissions at once.
  var locationPermissionStatus = Permission.location;

  if (locationPermissionStatus != PermissionStatus.granted) {
    PermissionStatus? locationRequestResult =
        await Permission.location.request();

    if (locationRequestResult != PermissionStatus.granted) {
      return;
    }
  }

  var getIt = GetIt.instance;
  getIt.registerSingleton(UserStorage());

  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Launch();
  }
}
