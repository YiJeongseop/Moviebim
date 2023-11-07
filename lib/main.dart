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
bool englishTest = true; // false for release
bool useRealAdId = false; // true for release
bool consentTest = false; // EU consent 대상이 된다. false for release
bool onDebug = true; // 광고가 안 나온다. false for release

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
    primary: Colors.black.withOpacity(0.9), // 텍스트
    onPrimary: Colors.transparent,
    secondary: Colors.transparent,
    onSecondary: Colors.transparent,
    error: Colors.black12, // Icons.image_not_supported_outlined
    onError: Colors.grey.withOpacity(0.9), // 검색창 돋보기, 전체(날짜 별로) 보기 텍스트 테두리,
    background: Colors.grey[50]!, // 배경, 스낵바 텍스트 + X아이콘, alert dialog 배경, 달력 dayNameColor activeDayColor
    onBackground: Colors.black.withOpacity(0.7), // 스낵바 배경, 앱바 아이콘, 바텀내비게이션바 unselectedItem, 달력 monthColor dayColor
    surface: Colors.grey.withOpacity(0.5), // 검색창 테두리, 추가창(수정창) 포스터 테두리, 리뷰창 테두리
    onSurface: Colors.white, // 검색창 배경, 리뷰창 배경, 전체(날짜 별로) 보기 텍스트 배경
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
    primary: Colors.white.withOpacity(0.9), // 텍스트
    onPrimary: Colors.transparent,
    secondary: Colors.transparent,
    onSecondary: Colors.transparent,
    error: Colors.grey.withOpacity(0.5), // Icons.image_not_supported_outlined
    onError: Colors.white.withOpacity(0.3), // 검색창 돋보기, 전체(날짜 별로) 보기 텍스트 테두리
    background: Colors.grey[800]!, // 배경, 스낵바 텍스트 + X아이콘, alert dialog 배경, 달력 dayNameColor activeDayColor
    onBackground: Colors.grey[300]!, // 스낵바 배경, 앱바 아이콘, 바텀내비게이션바 unselectedItem, 달력 monthColor dayColor
    surface: Colors.black.withOpacity(0.5), // 검색창 테두리, 추가창(수정창) 포스터 테두리, 리뷰창 테두리
    onSurface: Colors.black.withOpacity(0.24), // 검색창 배경, 리뷰창 배경, 전체(날짜 별로) 보기 텍스트 배경
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
