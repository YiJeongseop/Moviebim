import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controllers/basic_controller.dart';
import '../models/movie_model.dart';
import '../screens/home_screen.dart';
import '../services/admob_service.dart';
import '../services/google_service.dart';
import '../utilities/db_helper.dart';
import '../widgets/loading_widget.dart';
import '../main.dart';

AlertDialog loginAlertDialog(BuildContext context) {
  return AlertDialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    content: GestureDetector(
      onTap: () {
        signInWithGoogle(context);
      },
      child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.05,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/google_logo.png',
                width: MediaQuery.of(context).size.width * 0.08,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.01,
              ),
              Flexible(
                child: Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.048,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.01,
              ),
            ],
          ),
      ),
    ),
  );
}

AlertDialog tmdbAlertDialog(BuildContext context) {
  return AlertDialog(
    backgroundColor: Theme.of(context).colorScheme.background,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    content: SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/tmdb_logo.svg',
                width: MediaQuery.of(context).size.width * 0.44,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Text(
                AppLocalizations.of(context)!.tmdb,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.044,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

AlertDialog okCancelDialog(BuildContext context, String text, BasicController basicController, bool isUpload) {
  return AlertDialog(
    backgroundColor: Theme.of(context).colorScheme.background,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    content: Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    actions: [
      TextButton(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.teal[300]?.withOpacity(0.3)),
        ),
        onPressed: () async {
          Get.dialog(const LoadingWidget(), barrierDismissible: false);

          if(isUpload) {
            List<MovieModel> movies = [];
            for (int i = 0; i < basicController.savedMovies.length; i++){
              DateTime key = basicController.savedMovies[i].keys.first;
              movies += basicController.savedMovies[i][key];
            }

            await uploadToDrive(movies, context);

            try {
              if(!onDebug){
                callInterstitialAd();
                loadInterstitialAd();
              }
            } catch (e) {
              print("Error : $e");
            }
          } else {
            List<dynamic>? result = await downloadFromDrive(context);

            if(result != null) {
              basicController.savedMovies.value = result[0];
              basicController.savedMoviesStar.value = result[1];
              await dbHelper.deleteAllData();
              await dbHelper.insertAllData(basicController.savedMoviesStar);

              int sumOfRuntime = 0;
              for(int i = 0; i < 10; i++) {
                for(MovieModel movieModel in basicController.savedMoviesStar[i][indexToStar[i]]){
                  sumOfRuntime += movieModel.runtime;
                }
              }
              prefs.setInt('runtime', sumOfRuntime);
              basicController.entireRuntime.value = sumOfRuntime;

              try {
                if(!onDebug){
                  callInterstitialAd();
                  loadInterstitialAd();
                }
              } catch (e) {
                print("Error : $e");
              }

              Get.back();
              Get.back();
            }
          }
        },
        child: Text(
          AppLocalizations.of(context)!.ok,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      TextButton(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.teal[300]?.withOpacity(0.3)),
        ),
        onPressed: (){
          Get.back();
        },
        child: Text(
          AppLocalizations.of(context)!.cancel,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    ],
  );
}