import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/basic_controller.dart';
import '../controllers/pages_controller.dart';
import '../widgets/star_widget.dart';

class ListScreen extends StatelessWidget {
  ListScreen({Key? key}) : super(key: key);
  final BasicController basicController = Get.arguments;
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
                                errorBuilder: (context, object, stackTrace){
                                  return SizedBox(
                                    height: (deviceWidth / 4) * 1.5,
                                    width: deviceWidth / 4,
                                    child: Icon(
                                      Icons.close,
                                      color: Get.isDarkMode ? Colors.white54 : Colors.black54,
                                      size: deviceWidth * 0.2,
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
    Map<double, int> temp = {5 : 0, 4.5 : 1, 4 : 2, 3.5 : 3, 3 : 4, 2.5 : 5,
      2 : 6, 1.5 : 7, 1 : 8, 0.5 : 9};
    int returnValue = 0;
    if (isSortedByStar) {
      for(double i = 5; i > 0; i-=0.5){
        int temp2 = basicController.savedMoviesStar[temp[i]!][i].length;
        returnValue += temp2;
      }
      return returnValue;
    } else {
      for (int i = 0; i < basicController.savedMovies.length; i++) {
        for (DateTime key in basicController.savedMovies[i].keys) {
          int temp = basicController.savedMovies[i][key].length;
          returnValue += temp;
        }
      }
      return returnValue;
    }
  }

  List<dynamic> getListSortedByDate() {
    List<dynamic> returnList = [];
    for (int i = 0; i < basicController.savedMovies.length; i++){
     for (DateTime key in basicController.savedMovies[i].keys){
       returnList += basicController.savedMovies[i][key];
     }
    }
    return returnList;
  }

  List<dynamic> getListSortedByStar() {
    Map<double, int> temp = {5 : 0, 4.5 : 1, 4 : 2, 3.5 : 3, 3 : 4, 2.5 : 5,
      2 : 6, 1.5 : 7, 1 : 8, 0.5 : 9};
    List<dynamic> returnList = [];
    for(double i = 5; i > 0; i-=0.5){
      returnList += basicController.savedMoviesStar[temp[i]!][i];
    }
    return returnList;
  }
}
