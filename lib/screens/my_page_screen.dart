import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:moviebim/api_key.dart';
import 'package:moviebim/services/admob_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/basic_controller.dart';
import '../controllers/login_controller.dart';
import '../main.dart';
import '../models/movie_model.dart';
import '../services/google_service.dart';
import '../utilities/db_helper.dart';
import '../widgets/alert_widget.dart';
import '../screens/home_screen.dart';

class MyPageScreen extends StatelessWidget {
  MyPageScreen({Key? key, required this.basicController, required this.loginController}) : super(key: key);
  final BasicController basicController;
  final LoginController loginController;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  _saveThemeStatus(bool value) async {
    SharedPreferences pref = await _prefs;
    pref.setBool('theme', value);
  }

  _saveRuntime(int value) async {
    SharedPreferences pref = await _prefs;
    pref.setInt('runtime', value);
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
      request: const AdRequest(),
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
          const SizedBox(
            height: 50,
          ),
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
                  "${FirebaseAuth.instance.currentUser!.displayName!} \n ${FirebaseAuth.instance.currentUser!.email!}",
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                  textAlign: TextAlign.center,
                );
              } else {
                return Text(
                  "Guest",
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                );
              }
            },
          ),
          const Divider(color: Colors.white, thickness: 1),
          Obx(() => Text(
            "${basicController.entireRuntime.value ~/ 60}시간 ${basicController.entireRuntime.value % 60}분",
            style: TextStyle(
                color: Theme.of(context).primaryColorDark,
            ),
          )),
          StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData || loginController.isLogined.value) {
                  return ElevatedButton(
                      onPressed: () {
                        googleSignIn.disconnect();
                        // It makes the pop up to choose between Google accounts always come out.
                        FirebaseAuth.instance.signOut();
                        loginController.isLogined.value = false;
                      },
                      child: Text(
                        AppLocalizations.of(context)!.logout,
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: deviceWidth * 0.052,
                        ),
                      ),
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return loginAlertDialog(context);
                        },
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.login,
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: deviceWidth * 0.052,
                      ),
                    ),
                  );
                }
              },
          ),
          ElevatedButton(
              onPressed: (){
                callInterstitialAd();
                loadInterstitialAd();
                _saveThemeStatus(!Get.isDarkMode);
                Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,);
              },
              child: Text(
                AppLocalizations.of(context)!.changeTheme,
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: deviceWidth * 0.052,
                ),
              ),
          ),
          ElevatedButton(
              onPressed: (){
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return tmdbAlertDialog(context);
                  },
                );
              },
              child: Text(
                "Credits",
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: deviceWidth * 0.052,
                ),
              ),
          ),
          Obx(() => loginController.isLogined.value
              ? ElevatedButton(
                onPressed: () async {
                  Get.dialog(const LoadingOverlay(), barrierDismissible: false);

                  List<MovieModel> movies = [];
                  for (int i = 0; i < basicController.savedMovies.length; i++){
                    DateTime key = basicController.savedMovies[i].keys.first;
                    movies += basicController.savedMovies[i][key];
                  }

                  await uploadToDrive(movies, context);
                  Get.back();
                },
                child: Text(
                  AppLocalizations.of(context)!.save,
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: deviceWidth * 0.052,
                  ),
                ),
              )
              : const SizedBox.shrink()),
          Obx(() => loginController.isLogined.value
              ? ElevatedButton(
                onPressed: () async {
                  Get.dialog(const LoadingOverlay(), barrierDismissible: false);

                  List<dynamic>? result = await downloadFromDrive(context);
                  if(result == null) {
                    Get.back();
                  } else {
                    basicController.savedMovies.value = result[0];
                    basicController.savedMoviesStar.value = result[1];
                    await dbHelper.deleteAllData();
                    await dbHelper.insertAllData(basicController.savedMoviesStar);

                    int temp = 0;
                    for(int i = 0; i < 10; i++) {
                      for(MovieModel j in basicController.savedMoviesStar[i][star[i]]){
                        temp += j.runtime;
                      }
                    }
                    _saveRuntime(temp);
                    basicController.entireRuntime.value = temp;

                    Get.back();
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.load,
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: deviceWidth * 0.052,
                  ),
                ),
              )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}