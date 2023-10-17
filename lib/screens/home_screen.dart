import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/day_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DayController dayController = Get.put(DayController());
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Obx(
              () => CalendarTimeline(
                showYears: false,
                initialDate: dayController.selectedDate.value,
                firstDate: DateTime(2023, 10, 1),
                lastDate: DateTime(2028, 10, 1),
                onDateSelected: (date) => dayController.selectedDate.value = date,
                leftMargin: 10,
                monthColor: Get.isDarkMode ? Colors.white : Colors.black,
                dayColor: Get.isDarkMode ? Colors.teal[200] : Colors.teal[600],
                dayNameColor: const Color(0xFF333A47),
                activeDayColor: Colors.white,
                activeBackgroundDayColor: Colors.red[300],
                dotsColor: Get.isDarkMode ? Colors.white : Colors.black,
                locale: (defaultLocale == 'ko_KR') ? 'ko' : 'en',
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Get.isDarkMode ? Colors.teal[500] : Colors.black,
          child: Icon(Icons.add, color: Get.isDarkMode ? Colors.black : Colors.white, size: MediaQuery.of(context).size.width / 10,),
          onPressed: () {},
        ),
      ),
    );
  }
}
