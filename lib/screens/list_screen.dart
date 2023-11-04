import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/basic_controller.dart';
import '../controllers/list_controller.dart';
import '../utilities/db_helper.dart';
import '../widgets/star_widget.dart';

class ListScreen extends StatelessWidget {
  ListScreen({Key? key, required this.basicController}) : super(key: key);
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
          child: ListView.separated(
            itemCount: length,
            itemBuilder: (BuildContext context, int index) => Obx(() {
              return Column(
                children: [
                  if(index == 0)
                    const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network(
                            listController.sortedByStar.value
                                ? listSortedByStar[index].posterPath
                                : listSortedByDate[index].posterPath,
                            height: (deviceWidth / 4) * 1.5,
                            width: deviceWidth / 4,
                            fit: BoxFit.fill,
                            errorBuilder: (context, object, stackTrace) {
                              return SizedBox(
                                height: (deviceWidth / 4) * 1.5,
                                width: deviceWidth / 4,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Theme.of(context).colorScheme.error,
                                  size: deviceWidth * 0.2,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 5),
                          StarWidget(
                            rating: listController.sortedByStar.value
                                ? listSortedByStar[index].rating
                                : listSortedByDate[index].rating,
                            denominator: 4,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            height: (deviceWidth / 4) * 1.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurface,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.onError,
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: (deviceWidth / 4) * 2.35,
                                    child: Text(
                                      listController.sortedByStar.value
                                          ? listSortedByStar[index].title
                                          : listSortedByDate[index].title,
                                      softWrap: true,
                                      style: TextStyle(
                                        fontSize: deviceWidth * 0.04,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    width: (deviceWidth / 4) * 2.35,
                                    child: Text(
                                      listController.sortedByStar.value
                                          ? listSortedByStar[index].comment
                                          : listSortedByDate[index].comment,
                                      softWrap: true,
                                      style: TextStyle(
                                        fontSize: deviceWidth * 0.035,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            listController.sortedByStar.value
                                ? listSortedByStar[index].dateTime.toString().split(' ')[0]
                                : listSortedByDate[index].dateTime.toString().split(' ')[0],
                            style: TextStyle(
                              fontSize: deviceWidth * 0.04,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  if(length == index + 1)
                    const SizedBox(height: 20),
                ],
              );
            }),
            separatorBuilder: (BuildContext context, int index) {
              return Divider(color: Theme.of(context).dividerColor, thickness: 1);
            },
          ),
        ),
      ],
    );
  }
}
