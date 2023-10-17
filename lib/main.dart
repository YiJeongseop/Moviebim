import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moviebim/screens/home_screen.dart';

late final SharedPreferences _prefs;
late String defaultLocale;

ThemeData _lightTheme = ThemeData(
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0.0,
  ),
  primaryColor: Colors.white,
  primaryColorDark: Colors.black,
  brightness: Brightness.light,
);

ThemeData _darkTheme = ThemeData(
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    elevation: 0.0,
  ),
  primaryColor: Colors.black,
  primaryColorDark: Colors.white,
  brightness: Brightness.dark,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _prefs = await SharedPreferences.getInstance();
  defaultLocale = Platform.localeName;
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],
      locale: (defaultLocale == 'ko_KR') ? const Locale('ko') : const Locale('en'),
      title: (defaultLocale == 'ko_KR') ? '무비빔' : 'Moviebim',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
