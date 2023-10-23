import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:moviebim/controllers/login_controller.dart';
import 'package:moviebim/widgets/drawer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/basic_controller.dart';
import '../models/movie_model.dart';
import '../main.dart';
import '../utilities/db_helper.dart';
import '../widgets/star_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final dbHelper = DBHelper();

class _HomeScreenState extends State<HomeScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final BasicController basicController = Get.put(BasicController());
  final LoginController loginController = Get.put(LoginController());
  int listIndex = 0;
  bool isLoading = true;

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
    _initializeAsyncStuff();
    super.initState();
  }

  @override
  void dispose() {
    basicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        drawer: DrawerWidget(loginController: loginController),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          iconTheme: IconThemeData(
            color: Theme.of(context).primaryColorDark,
            size: deviceWidth / 12,
          ),
          leading: Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.only(top: 2),
                child: IconButton(
                  onPressed: (){
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(
                    Icons.menu,
                  ),
                  splashRadius: deviceWidth / 18,
                ),
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                _saveThemeStatus(!Get.isDarkMode);
                Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,);
              },
              icon: Icon(
                Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                size: deviceWidth / 12,
              ),
              splashRadius: deviceWidth / 18,
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            CalendarTimeline(
              showYears: false,
              initialDate: basicController.selectedDate.value,
              firstDate: DateTime(2023, 10, 1),
              lastDate: DateTime(2028, 10, 1),
              onDateSelected: (date) => basicController.selectedDate.value = DateTime(date.year, date.month, date.day),
              leftMargin: 10,
              monthColor: Get.isDarkMode ? Colors.white : Colors.black,
              dayColor: Get.isDarkMode ? Colors.teal[200] : Colors.teal[600],
              dayNameColor: Colors.black54,
              activeDayColor: Colors.white,
              activeBackgroundDayColor: Colors.red[300],
              dotsColor: Get.isDarkMode ? Colors.white : Colors.black,
              locale: englishTest ? 'en' : ((defaultLocale == 'ko_KR') ? 'ko' : 'en'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() => ListView.separated(
                itemCount: checkKeyInList(basicController.savedMovies, basicController.selectedDate.value)
                    ? basicController.savedMovies[listIndex][basicController.selectedDate.value].length
                    : 0,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 20),
                            child: Image.network(
                              basicController.savedMovies[listIndex][basicController.selectedDate.value][index].posterPath,
                              height: (deviceWidth / 3) * 1.5,
                              width: deviceWidth / 3,
                              fit: BoxFit.fill,
                              errorBuilder: (context, object, stackTrace){
                                return SizedBox(
                                  height: (deviceWidth / 3) * 1.5,
                                  width: deviceWidth / 3,
                                  child: Icon(
                                    Icons.close,
                                    color: Get.isDarkMode ? Colors.white54 : Colors.black54,
                                    size: deviceWidth * 0.25,
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: (deviceWidth / 3) * 1.55,
                                  child: Text(
                                    basicController.savedMovies[listIndex][basicController.selectedDate.value][index].title,
                                    softWrap: true,
                                    style: TextStyle(fontSize: deviceWidth * 0.04, color: Theme.of(context).primaryColorDark),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: (deviceWidth / 3) * 1.55,
                                  child: Text(
                                    basicController.savedMovies[listIndex][basicController.selectedDate.value][index].comment,
                                    softWrap: true,
                                    style: TextStyle(fontSize: deviceWidth * 0.035, color: Theme.of(context).primaryColorDark),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          StarWidget(
                            rating: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].rating,
                            widthNum: 3,
                          ),
                          Expanded(child: Container()),
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              child: Icon(Icons.edit, color: Get.isDarkMode ? Colors.white70 : Colors.black54),
                              onTap: () {
                                Get.toNamed('/edit', arguments: [basicController, listIndex, index]);
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              child: Icon(Icons.delete_forever_outlined, color: Get.isDarkMode ? Colors.white70 : Colors.black54),
                              onTap: () {
                                final movieModel = MovieModel(
                                  title: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].title,
                                  posterPath: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].posterPath,
                                  rating: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].rating,
                                  comment: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].comment,
                                  dateTime: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].dateTime,
                                );
                                deleteListStar(movieModel, basicController);
                                basicController.savedMovies[listIndex][basicController.selectedDate.value].removeAt(index);
                                if(basicController.savedMovies[listIndex][basicController.selectedDate.value].length == 0){
                                  basicController.savedMovies.removeAt(listIndex);
                                } else {
                                  var temp = basicController.savedMovies[listIndex];
                                  basicController.savedMovies.removeAt(listIndex);
                                  basicController.savedMovies.insert(listIndex, temp);
                                }
                                dbHelper.deleteData(movieModel.title, movieModel.posterPath, movieModel.rating, movieModel.comment, movieModel.dateTime);
                              },
                            ),
                          ),
                        ],
                      ),
                      if(basicController.savedMovies[listIndex][basicController.selectedDate.value].length == index + 1)
                        SizedBox(height: (deviceWidth / 3) * 1.5),
                    ],
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(color: Get.isDarkMode ? Colors.white70 : Colors.black12);
                },
              )),
            ),
          ],
        ),
        floatingActionButton: isLoading ? null : Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'changeView',
              elevation: 0.0,
              backgroundColor: Get.isDarkMode ? Colors.teal[400] : Colors.black,
              child: Icon(
                Icons.list,
                color: Get.isDarkMode ? Colors.black : Colors.white,
                size: deviceWidth / 10,
              ),
              onPressed: () {
                Get.toNamed('/list', arguments: basicController);
              },
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'add',
              elevation: 0.0,
              backgroundColor: Get.isDarkMode ? Colors.teal[400] : Colors.black,
              child: Icon(
                Icons.add,
                color: Get.isDarkMode ? Colors.black : Colors.white,
                size: deviceWidth / 10,
              ),
              onPressed: () {
                Get.toNamed('/add', arguments: basicController);
              },
            ),
          ],
        ),
      ),
    );
  }

  bool checkKeyInList(List list, DateTime target) {
    for(int i = 0; i < list.length; i++){
      if(list[i].containsKey(target)){
        listIndex = i;
        return true;
      }
    }
    return false;
  }
}

void deleteListStar(MovieModel movieModel, BasicController basicController) {
  Map<double, int> temp = {5 : 0, 4.5 : 1, 4 : 2, 3.5 : 3, 3 : 4, 2.5 : 5,
    2 : 6, 1.5 : 7, 1 : 8, 0.5 : 9};
  int index = temp[movieModel.rating]!;
  int j = 0;
  for(MovieModel i in basicController.savedMoviesStar[index][movieModel.rating]){
    if(i == movieModel) {
      basicController.savedMoviesStar[index][movieModel.rating].removeAt(j);
      break;
    }
    j++;
  }
}
