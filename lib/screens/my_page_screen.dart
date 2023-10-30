import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/basic_controller.dart';
import '../controllers/login_controller.dart';
import '../main.dart';
import '../api_key.dart';
import '../services/admob_service.dart';
import '../services/google_service.dart';
import '../widgets/alert_widget.dart';

class MyPageScreen extends StatelessWidget {
  MyPageScreen({Key? key, required this.basicController, required this.loginController}) : super(key: key);
  final BasicController basicController;
  final LoginController loginController;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  _saveThemeStatus(bool value) async {
    SharedPreferences pref = await _prefs;
    pref.setBool('theme', value);
  }

  @override
  Widget build(BuildContext context) {
    BannerAd banner = BannerAd(
      listener: BannerAdListener(
        onAdLoaded: (_) {},
        onAdFailedToLoad: (Ad ad, LoadAdError error) {},
      ),
      size: AdSize.banner,
      adUnitId: useRealAdId ? realBannerAdId : testBannerAdId,
      request: consentStatus == ConsentStatus.required ? const AdRequest(nonPersonalizedAds: true) : const AdRequest(),
    )..load();

    final deviceWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: AdWidget(
              ad: banner,
            ),
          ),
          Divider(color: Theme.of(context).dividerColor, thickness: 1),
          const SizedBox(
            height: 40,
          ),
          Column(
            children: [
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active && !snapshot.hasData) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      loginController.isLogined.value = false;
                    });
                  }
                  if (snapshot.hasData || loginController.isLogined.value) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      loginController.isLogined.value = true;
                    });
                    return Text(
                      englishTest
                          ? FirebaseAuth.instance.currentUser!.displayName!
                          : defaultLocale == 'ko_KR' ? "${FirebaseAuth.instance.currentUser!.displayName!}님," : FirebaseAuth.instance.currentUser!.displayName!,
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: deviceWidth * 0.06,
                      ),
                      textAlign: TextAlign.center,
                    );
                  } else {
                    return Text(
                      "",
                      style: TextStyle(fontSize: deviceWidth * 0.06)
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              Icon(
                Icons.access_time_outlined,
                size: deviceWidth * 0.15,
                color: Colors.teal[400]?.withOpacity(0.8),
              ),
              Obx(() => Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 20),
                child: Text(
                  "${basicController.entireRuntime.value ~/ 60} : ${basicController.entireRuntime.value % 60}",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: deviceWidth * 0.055,
                  ),
                  textAlign: TextAlign.center,
                ),
              )),
            ],
          ),
          Column(
            children: [
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData || loginController.isLogined.value) {
                    return Container(
                      width: deviceWidth * 0.8,
                      decoration: BoxDecoration(
                        color: Get.isDarkMode ? Colors.white.withOpacity(0.9) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          ),
                          onTap: (){
                            googleSignIn.disconnect();
                            FirebaseAuth.instance.signOut();
                            loginController.isLogined.value = false;
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.logout,
                                  size: deviceWidth * 0.08,
                                  color: Colors.black54,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.logout,
                                  style: TextStyle(
                                    color: Get.isDarkMode ? Colors.black : Theme.of(context).primaryColorDark,
                                    fontSize: deviceWidth * 0.052,
                                  ),
                                ),
                                Icon(
                                  Icons.file_copy_outlined,
                                  size: deviceWidth * 0.08,
                                  color: Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      width: deviceWidth * 0.8,
                      decoration: BoxDecoration(
                        color: Get.isDarkMode ? Colors.white.withOpacity(0.9) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          ),
                          onTap: (){
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return loginAlertDialog(context);
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.login,
                                  size: deviceWidth * 0.08,
                                  color: Colors.black54,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.login,
                                  style: TextStyle(
                                    color: Get.isDarkMode ? Colors.black : Theme.of(context).primaryColorDark,
                                    fontSize: deviceWidth * 0.048,
                                  ),
                                ),
                                Icon(
                                  Icons.file_copy_outlined,
                                  size: deviceWidth * 0.08,
                                  color: Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              Divider(
                height: 3,
                indent: deviceWidth * 0.1,
                endIndent: deviceWidth * 0.1,
                color: Theme.of(context).dividerColor,
              ),
              Container(
                width: deviceWidth * 0.8,
                decoration: BoxDecoration(
                    color: Get.isDarkMode ? Colors.white.withOpacity(0.9) : Colors.white,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: (){
                      if(!onDebug){
                        callInterstitialAd();
                        loadInterstitialAd();
                      }
                      _saveThemeStatus(!Get.isDarkMode);
                      Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            size: deviceWidth * 0.08,
                            color: Colors.black54,
                          ),
                          Text(
                            AppLocalizations.of(context)!.changeTheme,
                            style: TextStyle(
                              color: Get.isDarkMode ? Colors.black : Theme.of(context).primaryColorDark,
                              fontSize: deviceWidth * 0.052,
                            ),
                          ),
                          Icon(
                            Icons.file_copy_outlined,
                            size: deviceWidth * 0.08,
                            color: Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                  height: 3,
                  indent: deviceWidth * 0.1,
                  endIndent: deviceWidth * 0.1,
                  color: Theme.of(context).dividerColor,
              ),
              Container(
                width: deviceWidth * 0.8,
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Colors.white.withOpacity(0.9) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  )
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                    ),
                    onTap: (){
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return tmdbAlertDialog(context);
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.file_copy_outlined,
                            size: deviceWidth * 0.08,
                            color: Colors.black54,
                          ),
                          Text(
                            AppLocalizations.of(context)!.credits,
                            style: TextStyle(
                              color: Get.isDarkMode ? Colors.black : Theme.of(context).primaryColorDark,
                              fontSize: deviceWidth * 0.052,
                            ),
                          ),
                          Icon(
                            Icons.file_copy_outlined,
                            size: deviceWidth * 0.08,
                            color: Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 50),
          Column(
            children: [
              Container(
                width: deviceWidth * 0.8,
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Colors.white.withOpacity(0.9) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                    onTap: () async {
                      if(loginController.isLogined.value){
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return okCancelDialog(context, AppLocalizations.of(context)!.wantToSave, basicController, true);
                          },
                        );
                      } else {
                        showSnackbar(context, AppLocalizations.of(context)!.pleaseLogin);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.upload,
                            size: deviceWidth * 0.08,
                            color: Colors.black54,
                          ),
                          Text(
                            AppLocalizations.of(context)!.save,
                            style: TextStyle(
                              color: Get.isDarkMode ? Colors.black : Theme.of(context).primaryColorDark,
                              fontSize: deviceWidth * 0.042,
                            ),
                          ),
                          Icon(
                            Icons.file_copy_outlined,
                            size: deviceWidth * 0.08,
                            color: Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                height: 3,
                indent: deviceWidth * 0.1,
                endIndent: deviceWidth * 0.1,
                color: Theme.of(context).dividerColor,
              ),
              Container(
                width: deviceWidth * 0.8,
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Colors.white.withOpacity(0.9) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    onTap: () async {
                      if(loginController.isLogined.value) {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return okCancelDialog(context, AppLocalizations.of(context)!.wantToLoad, basicController, false);
                          },
                        );
                      } else {
                        showSnackbar(context, AppLocalizations.of(context)!.pleaseLogin);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.download,
                            size: deviceWidth * 0.08,
                            color: Colors.black54,
                          ),
                          Text(
                            AppLocalizations.of(context)!.load,
                            style: TextStyle(
                              color: Get.isDarkMode ? Colors.black : Theme.of(context).primaryColorDark,
                              fontSize: deviceWidth * 0.042,
                            ),
                          ),
                          Icon(
                            Icons.file_copy_outlined,
                            size: deviceWidth * 0.08,
                            color: Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}