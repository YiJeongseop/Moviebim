import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moviebim/services/admob_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controllers/login_controller.dart';
import '../controllers/basic_controller.dart';
import '../controllers/list_controller.dart';
import '../models/movie_model.dart';
import '../utilities/db_helper.dart';
import '../screens/calendar_screen.dart';
import 'list_screen.dart';
import 'my_page_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final dbHelper = DBHelper();

class _HomeScreenState extends State<HomeScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final BasicController basicController = Get.put(BasicController());
  final ListController listController = Get.put(ListController());
  final LoginController loginController = Get.put(LoginController());

  final List<Widget> _widgetOptions = [];
  bool isLoading = true;
  int _selectedIndex = 0;

  _getRuntime() async {
    SharedPreferences pref = await _prefs;
    final value = pref.getInt('runtime') ?? -1;
    if(value != -1){
      basicController.entireRuntime.value = value;
    }
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
    loadInterstitialAd();
    _getRuntime();
    _widgetOptions.add(CalendarScreen(basicController: basicController));
    _widgetOptions.add(ListScreen(basicController: basicController));
    _widgetOptions.add(MyPageScreen(basicController: basicController, loginController: loginController));
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
        appBar: isLoading || _selectedIndex == 2
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
                        color: Theme.of(context).primaryColorDark,
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
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month, size: deviceWidth / 15),
                    label: AppLocalizations.of(context)!.viewByDate,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list, size: deviceWidth / 15),
                    label: AppLocalizations.of(context)!.viewAll,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people, size: deviceWidth / 15),
                    label: AppLocalizations.of(context)!.myPage,
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
