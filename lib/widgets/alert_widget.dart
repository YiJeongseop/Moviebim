import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/google_service.dart';

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
          height: MediaQuery.of(context).size.height * 0.03,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/google_logo.png',
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
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.02,
              ),
            ],
          ),
      ),
    ),
  );
}

AlertDialog tmdbAlertDialog(BuildContext context) {
  return AlertDialog(
    backgroundColor: Colors.white,
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
                'This product uses the TMDb API but is not endorsed or certified by TMDb.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.044,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
