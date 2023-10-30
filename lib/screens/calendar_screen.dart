import 'package:flutter/material.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:get/get.dart';
import 'package:moviebim/widgets/painter_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/basic_controller.dart';
import '../main.dart';
import '../models/movie_model.dart';
import '../widgets/star_widget.dart';
import 'home_screen.dart';

class CalendarScreen extends StatelessWidget {
  CalendarScreen({Key? key, required this.basicController}) : super(key: key);

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final BasicController basicController;
  int listIndex = 0;

  _saveRuntime(int value) async {
    SharedPreferences pref = await _prefs;
    pref.setInt('runtime', value);
  }

  bool checkKeyInList(List list, DateTime target) {
    for (int i = 0; i < list.length; i++) {
      if (list[i].containsKey(target)) {
        listIndex = i;
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomPaint(
          size: Size(deviceWidth, 16),
          painter: LinePainter(),
        ),
        CalendarTimeline(
          showYears: false,
          initialDate: basicController.selectedDate.value,
          firstDate: DateTime(2023, 10, 1),
          lastDate: DateTime(2028, 10, 1),
          onDateSelected: (date) => basicController.selectedDate.value = DateTime(date.year, date.month, date.day),
          leftMargin: 10,
          monthColor: Get.isDarkMode ? Colors.white : Colors.black,
          dayColor: Get.isDarkMode ? Colors.teal[300] : Colors.teal[300],
          dayNameColor: Colors.black54,
          activeDayColor: Get.isDarkMode ? const Color(0xFF333333) : Colors.white,
          activeBackgroundDayColor: Colors.red[300],
          dotsColor: Get.isDarkMode ? const Color(0xFF333333) : Colors.grey[100],
          locale: englishTest ? 'en' : ((defaultLocale == 'ko_KR') ? 'ko' : 'en'),
        ),
        const SizedBox(height: 4),
        CustomPaint(
          size: Size(deviceWidth, 16),
          painter: LinePainter(),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() => ListView.separated(
            itemCount: checkKeyInList(basicController.savedMovies, basicController.selectedDate.value)
                ? basicController.savedMovies[listIndex][basicController.selectedDate.value].length
                : 0,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network(
                            basicController.savedMovies[listIndex][basicController.selectedDate.value][index].posterPath,
                            height: (deviceWidth / 3) * 1.5,
                            width: deviceWidth / 3,
                            fit: BoxFit.fill,
                            errorBuilder: (context, object, stackTrace){
                              return SizedBox(
                                height: (deviceWidth / 3) * 1.5,
                                width: deviceWidth / 3,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Get.isDarkMode ? Colors.white54 : Colors.black54,
                                  size: deviceWidth * 0.25,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 5),
                          StarWidget(
                            rating: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].rating,
                            denominator: 3,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(right: 10),
                            height: (deviceWidth / 3) * 1.5,
                            decoration: BoxDecoration(
                                color: Get.isDarkMode ? Colors.black.withOpacity(0.22) : Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.4),
                                )
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: (deviceWidth / 3) * 1.55,
                                    padding: const EdgeInsets.only(left: 5, top: 5),
                                    child: Text(
                                      basicController.savedMovies[listIndex][basicController.selectedDate.value][index].title,
                                      softWrap: true,
                                      style: TextStyle(fontSize: deviceWidth * 0.04, color: Theme.of(context).primaryColorDark),
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Container(
                                    width: (deviceWidth / 3) * 1.55,
                                    padding: const EdgeInsets.only(left: 5, bottom: 5),
                                    child: Text(
                                      basicController.savedMovies[listIndex][basicController.selectedDate.value][index].comment,
                                      softWrap: true,
                                      style: TextStyle(fontSize: deviceWidth * 0.035, color: Theme.of(context).primaryColorDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: InkWell(
                                  child: Icon(Icons.edit, color: Get.isDarkMode ? const Color(0xFFDDDDDD).withOpacity(0.55) : Colors.black54),
                                  onTap: () {
                                    Get.toNamed('/edit', arguments: [basicController, listIndex, index]);
                                  },
                                ),
                              ),
                              InkWell(
                                child: Icon(Icons.delete_forever_outlined, color: Get.isDarkMode ? const Color(0xFFDDDDDD).withOpacity(0.55) : Colors.black54),
                                onTap: () {
                                  final movieModel = MovieModel(
                                    title: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].title,
                                    posterPath: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].posterPath,
                                    rating: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].rating,
                                    comment: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].comment,
                                    dateTime: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].dateTime,
                                    runtime: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].runtime,
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
                                  dbHelper.deleteData(movieModel.title, movieModel.posterPath, movieModel.rating, movieModel.comment, movieModel.dateTime, movieModel.runtime);

                                  basicController.entireRuntime.value -= movieModel.runtime;
                                  _saveRuntime(basicController.entireRuntime.value);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  if(basicController.savedMovies[listIndex][basicController.selectedDate.value].length == index + 1)
                    const SizedBox(height: 20),
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(color: Get.isDarkMode ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.5), thickness: 1.1);
            },
          )),
        ),
      ],
    );
  }
}
