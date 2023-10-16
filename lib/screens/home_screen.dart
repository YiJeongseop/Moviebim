import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  _saveThemeStatus(bool value) async {
    SharedPreferences pref = await _prefs;
    pref.setBool('theme', value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                _saveThemeStatus(!Get.isDarkMode);
                Get.changeThemeMode(
                  Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                );
              },
              icon: Get.isDarkMode
                  ? Icon(
                      Icons.light_mode,
                      color: Colors.white,
                      size: MediaQuery.of(context).size.width / 13,
                    )
                  : Icon(
                      Icons.dark_mode,
                      color: Colors.black,
                      size: MediaQuery.of(context).size.width / 13,
                    ),
              splashRadius: MediaQuery.of(context).size.width / 18,
            ),
          ],
        ),
        body: Text(
          "Temp",
          style: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
      ),
    );
  }
}
