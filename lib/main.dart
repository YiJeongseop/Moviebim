import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../screens/add_screen.dart';
import '../screens/home_screen.dart';
import '../screens/edit_screen.dart';
import '../services/admob_service.dart';
import 'api_key.dart';

late final SharedPreferences prefs;
final String defaultLocale = Platform.localeName;
var consentStatus;
bool englishTest = false; // false for release
bool useRealAdId = true; // true for release
bool consentTest = false; // false for release
bool onDebug = false; // false for release

ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[50],
    elevation: 0.0,
  ),
  dividerColor: Colors.grey.withOpacity(0.5),
  cardColor: Colors.white,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: Colors.black.withOpacity(0.9),
    onPrimary: Colors.transparent,
    secondary: Colors.transparent,
    onSecondary: Colors.transparent,
    error: Colors.black12,
    onError: Colors.grey.withOpacity(0.9),
    background: Colors.grey[50]!,
    onBackground: Colors.black.withOpacity(0.7),
    surface: Colors.grey.withOpacity(0.5),
    onSurface: Colors.white,
  ),
  textTheme: englishTest
      ? GoogleFonts.robotoTextTheme()
      : ((defaultLocale == 'ko_KR') ? GoogleFonts.nanumGothicTextTheme() : GoogleFonts.robotoTextTheme()),
);

ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[800],
    elevation: 0.0,
  ),
  dividerColor: Colors.black.withOpacity(0.4),
  cardColor: Colors.black.withOpacity(0.04),
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: Colors.white.withOpacity(0.9),
    onPrimary: Colors.transparent,
    secondary: Colors.transparent,
    onSecondary: Colors.transparent,
    error: Colors.grey.withOpacity(0.5),
    onError: Colors.white.withOpacity(0.3),
    background: Colors.grey[800]!,
    onBackground: Colors.grey[300]!,
    surface: Colors.black.withOpacity(0.5),
    onSurface: Colors.black.withOpacity(0.24),
  ),
  textTheme: englishTest
      ? GoogleFonts.robotoTextTheme()
      : ((defaultLocale == 'ko_KR') ? GoogleFonts.nanumGothicTextTheme() : GoogleFonts.robotoTextTheme()),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  prefs = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  _getThemeStatus() async {
    final isDarkTheme = prefs.getBool('theme') ?? false;
    Get.changeThemeMode(isDarkTheme ? ThemeMode.dark : ThemeMode.light);
  }

  MyApp() {
    _getThemeStatus();

    final ConsentRequestParameters params;
    if(!consentTest){
      params = ConsentRequestParameters();
    } else {
      ConsentDebugSettings debugSettings = ConsentDebugSettings(
          debugGeography: DebugGeography.debugGeographyEea,
          testIdentifiers: [testId1, testId2]); // testId1, 2 are in hidden api_key.dart
      params = ConsentRequestParameters(consentDebugSettings: debugSettings);
    }

    ConsentInformation.instance.requestConsentInfoUpdate(params, () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        loadForm();
      }
    }, (error) {});

    loadInterstitialAd();
  }

  void loadForm() {
    ConsentForm.loadConsentForm((ConsentForm consentForm) async {
      consentStatus = await ConsentInformation.instance.getConsentStatus();
        if (consentStatus == ConsentStatus.required) {
          consentForm.show((formError) {});
        }
      }, (formError) {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // Prevent horizontal rotation
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
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomeScreen(), transition: Transition.noTransition),
        GetPage(name: '/add', page: () => const AddScreen(), transition: Transition.noTransition),
        GetPage(name: '/edit', page: () => const EditScreen(), transition: Transition.noTransition),
      ],
    );
  }
}
