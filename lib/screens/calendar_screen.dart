import 'package:flutter/material.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:get/get.dart';

import '../controllers/basic_controller.dart';
import '../main.dart';
import '../models/movie_model.dart';
import '../widgets/star_widget.dart';
import 'home_screen.dart';

class CalendarScreen extends StatelessWidget {
  CalendarScreen({Key? key, required this.basicController}) : super(key: key);

  final BasicController basicController;
  int listIndex = 0;

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
                        denominator: 3,
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
    );
  }
}
