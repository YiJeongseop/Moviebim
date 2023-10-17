import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/day_controller.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final DayController dayController = Get.put(DayController());

  _saveThemeStatus(bool value) async {
    SharedPreferences pref = await _prefs;
    pref.setBool('theme', value);
  }

  @override
  void dispose() {
    dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
                      size: MediaQuery.of(context).size.width / 12,
                    )
                  : Icon(
                      Icons.dark_mode,
                      color: Colors.black,
                      size: MediaQuery.of(context).size.width / 12,
                    ),
              splashRadius: MediaQuery.of(context).size.width / 18,
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            CalendarTimeline(
              showYears: false,
              initialDate: dayController.selectedDate.value,
              firstDate: DateTime(2023, 10, 1),
              lastDate: DateTime(2028, 10, 1),
              onDateSelected: (date) => dayController.selectedDate.value = date,
              leftMargin: 10,
              monthColor: Get.isDarkMode ? Colors.white : Colors.black,
              dayColor: Get.isDarkMode ? Colors.teal[200] : Colors.teal[600],
              dayNameColor: Colors.black54,
              activeDayColor: Colors.white,
              activeBackgroundDayColor: Colors.red[300],
              dotsColor: Get.isDarkMode ? Colors.white : Colors.black,
              locale: englishTest ? 'en' : ((defaultLocale == 'ko_KR') ? 'ko' : 'en'),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'changeView',
              elevation: 0.0,
              backgroundColor: Get.isDarkMode ? Colors.teal[400] : Colors.black,
              child: Icon(
                Icons.list,
                color: Get.isDarkMode ? Colors.black : Colors.white,
                size: MediaQuery.of(context).size.width / 10,
              ),
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'add',
              elevation: 0.0,
              backgroundColor: Get.isDarkMode ? Colors.teal[400] : Colors.black,
              child: Icon(
                Icons.add,
                color: Get.isDarkMode ? Colors.black : Colors.white,
                size: MediaQuery.of(context).size.width / 10,
              ),
              onPressed: () {
                Get.toNamed('/add', arguments: dayController);
              },
            ),
          ],
        ),
      ),
    );
  }
}
