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
bool englishTest = false;
bool httpResponseTest = false;
bool useRealAdId = false;
bool consentTest = false;
bool onDebug = true;

ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0.0,
  ),
  primaryColor: Colors.white,
  primaryColorDark: Colors.black,
  dividerColor: Colors.grey.withOpacity(0.5),
);

ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    elevation: 0.0,
  ),
  primaryColor: Colors.black,
  primaryColorDark: Colors.white,
  dividerColor: Colors.black.withOpacity(0.4),
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
    } else { // Test
      ConsentDebugSettings debugSettings = ConsentDebugSettings(
          debugGeography: DebugGeography.debugGeographyEea,
          testIdentifiers: [testId1, testId2]);
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // 가로 회전 막기
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
        GetPage(name: '/edit', page: () => const EditScreen(), transition: Transition.noTransition),
      ],
    );
  }
}
