import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/basic_controller.dart';
import '../controllers/list_controller.dart';
import '../utilities/db_helper.dart';
import '../widgets/alert_widget.dart';

class ListHorScreen extends StatelessWidget {
  ListHorScreen({Key? key, required this.basicController}) : super(key: key);
  final BasicController basicController;
  final ListController listController = Get.put(ListController());

  int getListLength() {
    int length = 0;
    for (double i = 5; i > 0; i -= 0.5) {
      int temp = basicController.savedMoviesStar[starToIndex[i]!][i].length;
      length += temp;
    }
    return length;
  }

  List<dynamic> getListSortedByDate() {
    List<dynamic> returnList = [];
    for (int i = 0; i < basicController.savedMovies.length; i++) {
      for (DateTime key in basicController.savedMovies[i].keys) {
        returnList += basicController.savedMovies[i][key];
      }
    }
    return returnList;
  }

  List<dynamic> getListSortedByStar() {
    List<dynamic> returnList = [];
    for (double i = 5; i > 0; i -= 0.5) {
      returnList += basicController.savedMoviesStar[starToIndex[i]!][i];
    }
    return returnList;
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final length = getListLength();
    final listSortedByStar = getListSortedByStar();
    final listSortedByDate = getListSortedByDate();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Theme.of(context).dividerColor, height: 1, thickness: 1),
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: (deviceWidth / 3.5) * 1.65,
            ),
            itemCount: length,
            itemBuilder: (context, index) {
              return Obx(() => Card(
                color: Theme.of(context).cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        final rating = listController.sortedByStar.value ? listSortedByStar[index].rating : listSortedByDate[index].rating;
                        final date = listController.sortedByStar.value ? listSortedByStar[index].dateTime : listSortedByDate[index].dateTime;
                        final comment = listController.sortedByStar.value ? listSortedByStar[index].comment : listSortedByDate[index].comment;
                        return detailAlertDialog(context, rating, date, comment);
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.transparent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          listController.sortedByStar.value
                              ? listSortedByStar[index].posterPath
                              : listSortedByDate[index].posterPath,
                          height: (deviceWidth / 3.55) * 1.5,
                          width: deviceWidth / 3.55,
                          fit: BoxFit.fill,
                          errorBuilder: (context, object, stackTrace){
                            return SizedBox(
                              height: (deviceWidth / 3.55) * 1.5,
                              width: deviceWidth / 3.55,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Theme.of(context).colorScheme.error,
                                size: deviceWidth * 0.2,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ));
            }
          )
        )
      ],
    );
  }
}
