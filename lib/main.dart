import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moviebim/screens/home_screen.dart';

late final SharedPreferences _prefs;

ThemeData _lightTheme = ThemeData(
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white70,
    elevation: 0.0,
  ),
  primaryColor: Colors.white,
  primaryColorDark: Colors.black,
  brightness: Brightness.light,
);

ThemeData _darkTheme = ThemeData(
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black38,
    elevation: 0.0,
  ),
  primaryColor: Colors.black54,
  primaryColorDark: Colors.white,
  brightness: Brightness.dark,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _prefs = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  _getThemeStatus() async {
    final isDarkTheme = _prefs.getBool('theme') ?? false;
    Get.changeThemeMode(isDarkTheme ? ThemeMode.dark : ThemeMode.light);
  }

  MyApp() {
    _getThemeStatus();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GetMaterialApp(
      title: 'Moviebim',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
