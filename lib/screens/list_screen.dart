import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/day_controller.dart';
import '../controllers/pages_controller.dart';
import '../models/movie_model.dart';
import '../widgets/star_widget.dart';

class ListScreen extends StatelessWidget {
  ListScreen({Key? key}) : super(key: key);
  final DayController dayController = Get.arguments;
  final PagesController pagesController = Get.put(PagesController());

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final length = getListLength(true);
    final listSortedByStar = getListSortedByStar();
    final listSortedByDate = getListSortedByDate();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            Obx(() => IconButton(
              onPressed: () {
                pagesController.sortedByStar.value = !pagesController.sortedByStar.value;
              },
              icon: Icon(
                pagesController.sortedByStar.value ? Icons.date_range : Icons.star,
                color: Get.isDarkMode ? Colors.white : Colors.black,
                size: deviceWidth / 12,
              ),
              splashRadius: deviceWidth / 18,
            ),),
            IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.close,
                color: Get.isDarkMode ? Colors.white : Colors.black,
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
            Expanded(
              child: ListView.separated(
                  itemCount: length,
                  itemBuilder: (BuildContext context, int index) => Obx(() {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10, right: 20),
                              child: Image.network(
                                pagesController.sortedByStar.value ? listSortedByStar[index].posterPath : listSortedByDate[index].posterPath,
                                height: (deviceWidth / 4) * 1.5,
                                width: deviceWidth / 4,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: (deviceWidth / 4) * 2.35,
                                    child: Text(
                                      pagesController.sortedByStar.value ? listSortedByStar[index].title : listSortedByDate[index].title,
                                      softWrap: true,
                                      style: TextStyle(fontSize: deviceWidth * 0.04, color: Theme.of(context).primaryColorDark),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: (deviceWidth / 4) * 2.35,
                                    child: Text(
                                      pagesController.sortedByStar.value ? listSortedByStar[index].comment : listSortedByDate[index].comment,
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
                              rating: pagesController.sortedByStar.value
                                  ? listSortedByStar[index].rating
                                  : listSortedByDate[index].rating,
                              widthNum: 4,
                            ),
                            Expanded(child: Container()),
                            Padding(
                              padding: const EdgeInsets.only(right: 10, top: 5),
                              child: Text(
                                pagesController.sortedByStar.value
                                    ? listSortedByStar[index].dateTime.toString().split(' ')[0]
                                    : listSortedByDate[index].dateTime.toString().split(' ')[0],
                                style: TextStyle(fontSize: deviceWidth * 0.04, color: Theme.of(context).primaryColorDark),
                              ),
                            )
                          ],
                        ),
                      ],
                    );
                  }),
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(color: Get.isDarkMode ? Colors.white70 : Colors.black12);
                  },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int getListLength(bool isSortedByStar) {
    int returnValue = 0;
    if (isSortedByStar) {
      int temp = dayController.savedMoviesStar[0][5].length;
      returnValue += temp;
      temp = dayController.savedMoviesStar[1][4.5].length;
      returnValue += temp;
      temp = dayController.savedMoviesStar[2][4].length;
      returnValue += temp;
      temp = dayController.savedMoviesStar[3][3.5].length;
      returnValue += temp;
      temp = dayController.savedMoviesStar[4][3].length;
      returnValue += temp;
      temp = dayController.savedMoviesStar[5][2.5].length;
      returnValue += temp;
      temp = dayController.savedMoviesStar[6][2].length;
      returnValue += temp;
      temp = dayController.savedMoviesStar[7][1.5].length;
      returnValue += temp;
      temp = dayController.savedMoviesStar[8][1].length;
      returnValue += temp;
      temp = dayController.savedMoviesStar[9][0.5].length;
      returnValue += temp;
      return returnValue;
    } else {
      for (int i = 0; i < dayController.savedMovies.length; i++) {
        for (DateTime key in dayController.savedMovies[i].keys) {
          int temp = dayController.savedMovies[i][key].length;
          returnValue += temp;
        }
      }
      return returnValue;
    }
  }

  List<dynamic> getListSortedByDate() {
    List<dynamic> returnList = [];
    for (int i = 0; i < dayController.savedMovies.length; i++){
     for (DateTime key in dayController.savedMovies[i].keys){
       returnList += dayController.savedMovies[i][key];
     }
    }
    return returnList;
  }

  List<dynamic> getListSortedByStar() {
    List<dynamic> returnList = [];
    returnList += dayController.savedMoviesStar[0][5];
    returnList += dayController.savedMoviesStar[1][4.5];
    returnList += dayController.savedMoviesStar[2][4];
    returnList += dayController.savedMoviesStar[3][3.5];
    returnList += dayController.savedMoviesStar[4][3];
    returnList += dayController.savedMoviesStar[5][2.5];
    returnList += dayController.savedMoviesStar[6][2];
    returnList += dayController.savedMoviesStar[7][1.5];
    returnList += dayController.savedMoviesStar[8][1];
    returnList += dayController.savedMoviesStar[9][0.5];
    return returnList;
  }
}
