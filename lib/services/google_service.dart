import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope, drive.DriveApi.driveAppdataScope]
);

Future<bool> signInWithGoogle(BuildContext context) async {
  Get.dialog(const LoadingOverlay(), barrierDismissible: false);
  GoogleSignInAccount? googleUser;

  try{
    googleUser = await googleSignIn.signIn();
  } catch (e) {
    Get.back();
    Get.back();
    Get.back();
    showSnackbar(context);
    return false;
  }

  if(googleUser == null){
    Get.back();
    showSnackbar(context);
    return false;
  }

  try{
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    Get.back();
    Get.back();
    Get.back();
    return true;
  } catch (e) {
    Get.back();
    showSnackbar(context);
    return false;
  }
}

void showSnackbar(BuildContext context){
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.loginFail,
          textAlign: TextAlign.center,
        ),
        showCloseIcon: true,
        closeIconColor: Get.isDarkMode ? Colors.black : Colors.white,
        duration: const Duration(seconds: 5),
      )
  );
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        ModalBarrier(
          color: Colors.black54,
          dismissible: false,
        ),
        Center(
          child: CircularProgressIndicator(),
        )
      ],
    );
  }
}