import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../screens/add_screen.dart';
import '../screens/home_screen.dart';

late final SharedPreferences _prefs;
final String defaultLocale = Platform.localeName;
bool englishTest = false;
bool httpResponseTest = false;

ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0.0,
  ),
  primaryColor: Colors.white,
  primaryColorDark: Colors.black,
);

ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    elevation: 0.0,
  ),
  primaryColor: Colors.black,
  primaryColorDark: Colors.white,
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
      locale: englishTest
          ? const Locale('en')
          : ((defaultLocale == 'ko_KR') ? const Locale('ko') : const Locale('en')),
      title: (defaultLocale == 'ko_KR') ? '무비빔' : 'Moviebim',
      theme: _lightTheme.copyWith(
        textTheme: englishTest
            ? GoogleFonts.robotoTextTheme()
            : ((defaultLocale == 'ko_KR') ? GoogleFonts.nanumGothicTextTheme() : GoogleFonts.robotoTextTheme()),
      ),
      darkTheme: _darkTheme.copyWith(
        textTheme: englishTest
            ? GoogleFonts.robotoTextTheme()
            : ((defaultLocale == 'ko_KR') ? GoogleFonts.nanumGothicTextTheme() : GoogleFonts.robotoTextTheme()),
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomeScreen(), transition: Transition.noTransition),
        GetPage(name: '/add', page: () => const AddScreen(), transition: Transition.noTransition),
      ],
    );
  }
}
