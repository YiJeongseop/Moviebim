import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:intl/intl.dart';
import 'package:moviebim/models/movie_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/day_controller.dart';
import '../main.dart';
import '../widgets/star_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final DayController dayController = Get.put(DayController());
  int listIndex = 0;

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
    final deviceWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                _saveThemeStatus(!Get.isDarkMode);
                Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,);
              },
              icon: Get.isDarkMode
                  ? Icon(
                      Icons.light_mode,
                      color: Colors.white,
                      size: deviceWidth / 12,
                    )
                  : Icon(
                      Icons.dark_mode,
                      color: Colors.black,
                      size: deviceWidth / 12,
                    ),
              splashRadius: deviceWidth / 18,
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
              onDateSelected: (date) => dayController.selectedDate.value = DateTime(date.year, date.month, date.day),
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
                itemCount: checkKeyInList(dayController.savedMovies, dayController.selectedDate.value)
                    ? dayController.savedMovies[listIndex][dayController.selectedDate.value].length
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
                              dayController.savedMovies[listIndex][dayController.selectedDate.value][index].posterPath,
                              height: (deviceWidth / 3) * 1.5,
                              width: deviceWidth / 3,
                              fit: BoxFit.fill,
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
                                    dayController.savedMovies[listIndex][dayController.selectedDate.value][index].title,
                                    softWrap: true,
                                    style: TextStyle(fontSize: deviceWidth * 0.04, color: Theme.of(context).primaryColorDark),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: (deviceWidth / 3) * 1.55,
                                  child: Text(
                                    dayController.savedMovies[listIndex][dayController.selectedDate.value][index].comment,
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
                            rating: dayController.savedMovies[listIndex][dayController.selectedDate.value][index].rating,
                            widthNum: 3,
                          ),
                          Expanded(child: Container()),
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              child: Icon(Icons.edit, color: Get.isDarkMode ? Colors.white70 : Colors.black54),
                              onTap: () {
                                Get.toNamed('/edit', arguments: [dayController, listIndex, index]);
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              child: Icon(Icons.delete_forever_outlined, color: Get.isDarkMode ? Colors.white70 : Colors.black54),
                              onTap: () {
                                final movieModel = MovieModel(
                                  title: dayController.savedMovies[listIndex][dayController.selectedDate.value][index].title,
                                  posterPath: dayController.savedMovies[listIndex][dayController.selectedDate.value][index].posterPath,
                                  rating: dayController.savedMovies[listIndex][dayController.selectedDate.value][index].rating,
                                  comment: dayController.savedMovies[listIndex][dayController.selectedDate.value][index].comment,
                                  dateTime: dayController.savedMovies[listIndex][dayController.selectedDate.value][index].dateTime,
                                );
                                deleteListStar(movieModel, dayController);
                                dayController.savedMovies[listIndex][dayController.selectedDate.value].removeAt(index);
                                if(dayController.savedMovies[listIndex][dayController.selectedDate.value].length == 0){
                                  dayController.savedMovies.removeAt(listIndex);
                                } else {
                                  var temp = dayController.savedMovies[listIndex];
                                  dayController.savedMovies.removeAt(listIndex);
                                  dayController.savedMovies.insert(listIndex, temp);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      if(dayController.savedMovies[listIndex][dayController.selectedDate.value].length == index + 1)
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
                size: deviceWidth / 10,
              ),
              onPressed: () {
                Get.toNamed('/list', arguments: dayController);
                // print("dayController.savedMovies : ${dayController.savedMovies}");
                // print("dayController.selectedDate : ${dayController.selectedDate}");
                // print("dayController.savedMoviesStar : ${dayController.savedMoviesStar}");
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
                Get.toNamed('/add', arguments: dayController);
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

void deleteListStar(MovieModel movieModel, DayController dayController) {
  int j = 0;
  switch (movieModel.rating){
    case 5:
      for(MovieModel i in dayController.savedMoviesStar[0][5]){
        if(i == movieModel) {
          dayController.savedMoviesStar[0][5].removeAt(j);
          break;
        }
        j++;
      }
      break;
    case 4.5:
      for(MovieModel i in dayController.savedMoviesStar[1][4.5]){
        if(i == movieModel) {
          dayController.savedMoviesStar[1][4.5].removeAt(j);
          break;
        }
        j++;
      }
      break;
    case 4:
      for(MovieModel i in dayController.savedMoviesStar[2][4]){
        if(i == movieModel) {
          dayController.savedMoviesStar[2][4].removeAt(j);
          break;
        }
        j++;
      }
      break;
    case 3.5:
      for(MovieModel i in dayController.savedMoviesStar[3][3.5]){
        if(i == movieModel) {
          dayController.savedMoviesStar[3][3.5].removeAt(j);
          break;
        }
        j++;
      }
      break;
    case 3:
      for(MovieModel i in dayController.savedMoviesStar[4][3]){
        if(i == movieModel) {
          dayController.savedMoviesStar[4][3].removeAt(j);
          break;
        }
        j++;
      }
      break;
    case 2.5:
      for(MovieModel i in dayController.savedMoviesStar[5][2.5]){
        if(i == movieModel) {
          dayController.savedMoviesStar[5][2.5].removeAt(j);
          break;
        }
        j++;
      }
      break;
    case 2:
      for(MovieModel i in dayController.savedMoviesStar[6][2]){
        if(i == movieModel) {
          dayController.savedMoviesStar[6][2].removeAt(j);
          break;
        }
        j++;
      }
      break;
    case 1.5:
      for(MovieModel i in dayController.savedMoviesStar[7][1.5]){
        if(i == movieModel) {
          dayController.savedMoviesStar[7][1.5].removeAt(j);
          break;
        }
        j++;
      }
      break;
    case 1:
      for(MovieModel i in dayController.savedMoviesStar[8][1]){
        if(i == movieModel) {
          dayController.savedMoviesStar[8][1].removeAt(j);
          break;
        }
        j++;
      }
      break;
    case 0.5:
      for(MovieModel i in dayController.savedMoviesStar[9][0.5]){
        if(i == movieModel) {
          dayController.savedMoviesStar[9][0.5].removeAt(j);
          break;
        }
        j++;
      }
      break;
    default:
  }
}
