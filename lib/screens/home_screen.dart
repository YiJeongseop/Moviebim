import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/login_controller.dart';
import '../controllers/basic_controller.dart';
import '../controllers/list_controller.dart';
import '../models/movie_model.dart';
import '../utilities/db_helper.dart';
import '../screens/calendar_screen.dart';
import 'list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final dbHelper = DBHelper();

class _HomeScreenState extends State<HomeScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late final BasicController basicController = Get.put(BasicController());
  final ListController listController = Get.put(ListController());
  final LoginController loginController = Get.put(LoginController());

  final List<Widget> _widgetOptions = [];
  bool isLoading = true;
  int _selectedIndex = 0;

  _saveThemeStatus(bool value) async {
    SharedPreferences pref = await _prefs;
    pref.setBool('theme', value);
  }

  Future<void> _initializeAsyncStuff() async {
    List<dynamic> returnList = await dbHelper.getData();
    basicController.savedMovies.value = returnList[0];
    basicController.savedMoviesStar.value = returnList[1];
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    _widgetOptions.add(CalendarScreen(basicController: basicController));
    _widgetOptions.add(ListScreen(basicController: basicController));
    _initializeAsyncStuff();
    super.initState();
  }

  @override
  void dispose() {
    basicController.dispose();
    listController.dispose();
    loginController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: isLoading
            ? null
            : AppBar(
                automaticallyImplyLeading: false,
                actions: [
                  if(_selectedIndex == 0)
                    IconButton(
                      onPressed: () {
                        Get.toNamed('/add', arguments: basicController);
                      },
                      icon: Icon(
                        Icons.add,
                        size: deviceWidth / 12,
                      ),
                      splashRadius: deviceWidth / 18,
                    ),
                  if(_selectedIndex == 1)
                    Obx(() => IconButton(
                        onPressed: () {
                          listController.sortedByStar.value = !listController.sortedByStar.value;
                        },
                        icon: Icon(
                          listController.sortedByStar.value ? Icons.date_range : Icons.star,
                          color: Theme.of(context).primaryColorDark,
                          size: deviceWidth / 12,
                        ),
                        splashRadius: deviceWidth / 18,
                    )),
                ],
              ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _widgetOptions[_selectedIndex],
        bottomNavigationBar: isLoading
            ? null
            : BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month),
                    label: '날짜 별로 보기',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list),
                    label: '전체 보기',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people),
                    label: '마이페이지',
                  ),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
      ),
    );
  }
}

void deleteListStar(MovieModel movieModel, BasicController basicController) {
  Map<double, int> temp = {
    5: 0,
    4.5: 1,
    4: 2,
    3.5: 3,
    3: 4,
    2.5: 5,
    2: 6,
    1.5: 7,
    1: 8,
    0.5: 9
  };
  int index = temp[movieModel.rating]!;
  int j = 0;
  for (MovieModel i in basicController.savedMoviesStar[index][movieModel.rating]) {
    if (i == movieModel) {
      basicController.savedMoviesStar[index][movieModel.rating].removeAt(j);
      break;
    }
    j++;
  }
}
