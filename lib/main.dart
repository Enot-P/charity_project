import 'dart:io';
import 'package:charity_project/charity_app_home_screen.dart';
import 'package:charity_project/create_event/create_event_screen.dart';
import 'package:charity_project/event_profile/event_profile_screen.dart';
import 'package:charity_project/fond_profile/fond_profile_screen.dart';
import 'package:charity_project/login/login_page.dart';
import 'package:charity_project/models/event_data.dart';
import 'package:charity_project/models/fond_data.dart';
import 'package:charity_project/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  initializeDateFormatting('ru', null).then((_) {
    runApp(const MyApp());
  });
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  get fondData => null;

  get eventData => null;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
      !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    int userData = -1;
    return MaterialApp(
      title: 'Flutter UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/fondList': (context) => CharityAppHomeScreen(userId: userData,),
        '/fondProfile' : (context) => FondProfileScreen(fond: fondData),
        '/eventProfile' : (context) => EventProfileScreen(event: eventData),
        '/createEvent' : (context) => const CreateEventScreen(),
        '/' : (context) => const LoginPage(),
      },
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}
