import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../controllers/login_controller.dart';
import '../services/google_service.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key, required this.loginController}) : super(key: key);
  final LoginController loginController;

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: deviceWidth / 2,
      child: Drawer(
        backgroundColor: Theme.of(context).primaryColor,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Stack(
                    children: [
                      StreamBuilder<User?>(
                        stream: FirebaseAuth.instance.authStateChanges(),
                        builder: (context, snapshot) {
                          if(snapshot.connectionState == ConnectionState.active && !snapshot.hasData){
                            loginController.isLogined.value = false;
                          }
                          if(snapshot.hasData || loginController.isLogined.value){
                            loginController.isLogined.value = true;
                            return SizedBox(
                              height: deviceHeight * 0.12,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(15),
                                ),
                                child: userAccountsDrawerHeader(
                                  displayName: FirebaseAuth.instance.currentUser!.displayName!,
                                  email: FirebaseAuth.instance.currentUser!.email!,
                                  deviceWidth: deviceWidth,
                                ),
                              ),
                            );
                          } else{
                            return SizedBox(
                              height: deviceHeight * 0.12,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(15),
                                ),
                                child: userAccountsDrawerHeader(
                                  displayName: '',
                                  email: '',
                                  deviceWidth: deviceWidth,
                                ),
                              ),
                            );
                          }
                        }
                      ),
                    ],
                  ),
                  StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData || loginController.isLogined.value){
                        return ListTile(
                          minLeadingWidth : 20,
                          leading: Icon(
                            Icons.logout,
                            size: 30,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.logout,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: deviceWidth * 0.052,
                            ),
                          ),
                          onTap: () {
                            googleSignIn.disconnect();
                            // It makes the pop up to choose between Google accounts always come out.
                            FirebaseAuth.instance.signOut();
                            loginController.isLogined.value = false;
                            Get.back();
                          },
                        );
                      } else {
                        return ListTile(
                          minLeadingWidth : 20,
                          leading: Icon(
                            Icons.login,
                            size: deviceWidth * 0.08,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.login,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: deviceWidth * 0.052,
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return loginAlertDialog(context);
                              }
                            );
                          },
                        );
                      }
                    }
                  )
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}

UserAccountsDrawerHeader userAccountsDrawerHeader({
  required String displayName,
  required String email,
  required double deviceWidth,
}){
  return UserAccountsDrawerHeader(
    decoration: BoxDecoration(
      color: Get.isDarkMode
          ? Colors.teal[300]
          : Colors.teal[200]),
    margin: const EdgeInsets.only(bottom: 0.0),
    accountName: Text(
      displayName,
      style: TextStyle(
        fontSize: deviceWidth * 0.055,
        color: Colors.black87,
      ),
    ),
    accountEmail: Text(
      email,
      style: TextStyle(
        fontSize: deviceWidth * 0.04,
        color: Colors.black87,
      ),
    ),
  );
}

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
        height: MediaQuery.of(context).size.height * 0.04,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/google_logo.png',
              // https://about.google/brand-resource-center/logos-list/
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
            Flexible(
              child: Text(
                'Sign in with Google',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                ),
              ),
            ),
          ],
        )
      ),
    ),
  );
}