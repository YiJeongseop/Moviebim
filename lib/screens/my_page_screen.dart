import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/basic_controller.dart';
import '../controllers/login_controller.dart';
import '../services/admob_service.dart';
import '../services/google_service.dart';
import '../utilities/snack_bar.dart';
import '../widgets/alert_widget.dart';
import '../api_key.dart';
import '../main.dart';

enum ButtonType {logout, login, theme, credits, save, load}

class MyPageScreen extends StatelessWidget {
  MyPageScreen({Key? key, required this.basicController, required this.loginController})
      : super(key: key);
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
                      FirebaseAuth.instance.currentUser!.displayName!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: deviceWidth * 0.063,
                      ),
                      textAlign: TextAlign.center,
                    );
                  } else {
                    return Text(
                      "",
                      style: TextStyle(fontSize: deviceWidth * 0.063)
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              Icon(
                Icons.access_time_outlined,
                size: deviceWidth * 0.15,
                color: Colors.teal[300],
              ),
              Obx(() => Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 20),
                child: Text(
                  englishTest
                      ? "${basicController.entireRuntime.value ~/ 60}h ${basicController.entireRuntime.value % 60}m"
                      : (defaultLocale == 'ko_KR') ? "${basicController.entireRuntime.value ~/ 60}시간 ${basicController.entireRuntime.value % 60}분" : "${basicController.entireRuntime.value ~/ 60}h ${basicController.entireRuntime.value % 60}m",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: deviceWidth * 0.06,
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
                    return buttonContainer(
                      deviceWidth: deviceWidth,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                      buttonType: ButtonType.logout,
                      iconData: Icons.logout,
                      text: AppLocalizations.of(context)!.logout,
                      fontSize: deviceWidth * 0.052,
                      context: context,
                    );
                  } else {
                    return buttonContainer(
                      deviceWidth: deviceWidth,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                      buttonType: ButtonType.login,
                      iconData: Icons.login,
                      text: AppLocalizations.of(context)!.login,
                      fontSize: deviceWidth * 0.052,
                      context: context,
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
              buttonContainer(
                deviceWidth: deviceWidth,
                borderRadius: null,
                buttonType: ButtonType.theme,
                iconData: Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                text: AppLocalizations.of(context)!.changeTheme,
                fontSize: deviceWidth * 0.052,
                context: context,
              ),
              Divider(
                  height: 3,
                  indent: deviceWidth * 0.1,
                  endIndent: deviceWidth * 0.1,
                  color: Theme.of(context).dividerColor,
              ),
              buttonContainer(
                deviceWidth: deviceWidth,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                buttonType: ButtonType.credits,
                iconData: Icons.file_copy_outlined,
                text: AppLocalizations.of(context)!.credits,
                fontSize: deviceWidth * 0.052,
                context: context,
              ),
            ],
          ),
          const SizedBox(height: 50),
          Column(
            children: [
              buttonContainer(
                deviceWidth: deviceWidth,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
                buttonType: ButtonType.save,
                iconData: Icons.upload,
                text: AppLocalizations.of(context)!.save,
                fontSize: deviceWidth * 0.042,
                context: context,
              ),
              Divider(
                height: 3,
                indent: deviceWidth * 0.1,
                endIndent: deviceWidth * 0.1,
                color: Theme.of(context).dividerColor,
              ),
              buttonContainer(
                deviceWidth: deviceWidth,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                buttonType: ButtonType.load,
                iconData: Icons.download,
                text: AppLocalizations.of(context)!.load,
                fontSize: deviceWidth * 0.042,
                context: context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container buttonContainer({required double deviceWidth, required BorderRadius? borderRadius,
    required ButtonType buttonType, required IconData iconData, required String text,
    required double fontSize, required BuildContext context
  }){
    return Container(
      width: deviceWidth * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: (){
            if (buttonType == ButtonType.logout){
              googleSignIn.disconnect();
              FirebaseAuth.instance.signOut();
              loginController.isLogined.value = false;
            } else if (buttonType == ButtonType.login) {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return loginAlertDialog(context);
                },
              );
            } else if (buttonType == ButtonType.theme) {
              try{
                if(!onDebug){
                  callInterstitialAd();
                  loadInterstitialAd();
                }
              } catch (e) {
                print("Error : $e");
              } finally {
                _saveThemeStatus(!Get.isDarkMode);
                Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
              }
            } else if (buttonType == ButtonType.credits) {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return tmdbAlertDialog(context);
                },
              );
            } else if (buttonType == ButtonType.save) {
              if(loginController.isLogined.value){
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return okCancelDialog(context, AppLocalizations.of(context)!.wantToSave, basicController, true);
                  },
                );
              } else {
                showSnackBar(context, AppLocalizations.of(context)!.pleaseLogin);
              }
            } else if (buttonType == ButtonType.load) {
              if(loginController.isLogined.value) {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return okCancelDialog(context, AppLocalizations.of(context)!.wantToLoad, basicController, false);
                  },
                );
              } else {
                showSnackBar(context, AppLocalizations.of(context)!.pleaseLogin);
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  iconData,
                  size: deviceWidth * 0.08,
                  color: Colors.black.withOpacity(0.5),
                ),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.9),
                    fontSize: fontSize,
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
}