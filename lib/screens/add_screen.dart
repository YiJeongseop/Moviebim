import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/add_page_controller.dart';
import '../screens/home_screen.dart';
import '../models/movie_model.dart';
import '../controllers/movie_controller.dart';
import '../controllers/text_controller.dart';
import '../controllers/basic_controller.dart';
import '../utilities/db_helper.dart';
import '../widgets/search_widget.dart';
import '../widgets/add_widget.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final BasicController basicController = Get.arguments;
  final TextController textController = Get.put(TextController());
  final MovieController movieController = Get.put(MovieController());
  final AddPageController addPageController = Get.put(AddPageController());
  FocusNode textFocus = FocusNode();

  @override
  void dispose() {
    textController.dispose();
    movieController.dispose();
    addPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          textFocus.unfocus();
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: Obx(
              () => addPageController.pageNumber.value == 2
                  ? IconButton(
                      onPressed: () {
                        movieController.selectedMovie.clear();
                        addPageController.pageNumber.value = 1;
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Get.isDarkMode ? Colors.white : Colors.black,
                        size: deviceWidth / 12,
                      ),
                      splashRadius: deviceWidth / 18,
                    )
                  : const SizedBox.shrink(),
            ),
            actions: [
              Obx(
                () => (addPageController.pageNumber.value == 1)
                    ? IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(
                          Icons.close,
                          color: Get.isDarkMode ? Colors.white : Colors.black,
                          size: deviceWidth / 12,
                        ),
                        splashRadius: deviceWidth / 18,
                      )
                    : IconButton(
                        onPressed: () {
                          final movieModel = MovieModel(
                            title: movieController.selectedMovie[0]['title'],
                            posterPath: 'https://image.tmdb.org/t/p/w500${movieController.selectedMovie[0]['poster_path']}',
                            rating: movieController.movieRating.value,
                            comment: textController.movieComment.value,
                            dateTime: basicController.selectedDate.value,
                          );
                          final dateExist = basicController.savedMovies.any((map) => map.containsKey(basicController.selectedDate.value));
                          if(dateExist){
                            for(int i = 0; i < basicController.savedMovies.length; i++){
                              if(basicController.savedMovies[i].containsKey(basicController.selectedDate.value)){
                                basicController.savedMovies[i][basicController.selectedDate.value].add(movieModel);
                                break;
                              }
                            }
                          } else if (basicController.savedMovies.isEmpty) {
                            basicController.savedMovies.add(
                              {
                                basicController.selectedDate.value: [movieModel]
                              },
                            );
                          } else {
                            int i = 0;
                            for (Map<DateTime, dynamic> map in basicController.savedMovies){
                              DateTime temp = map.keys.toList()[0];
                              if(temp.microsecondsSinceEpoch > basicController.selectedDate.value.microsecondsSinceEpoch){
                                basicController.savedMovies.insert(i,
                                  {
                                    basicController.selectedDate.value: [movieModel]
                                  },
                                );
                                break;
                              }
                              i++;
                              if(i == basicController.savedMovies.length){
                                basicController.savedMovies.add(
                                  {
                                    basicController.selectedDate.value: [movieModel]
                                  },
                                );
                                break;
                              }
                            }
                          }
                          saveToListStar(movieModel, basicController);

                          dbHelper.insertData({
                            columnTitle: movieModel.title,
                            columnPosterPath: movieModel.posterPath,
                            columnRating: movieModel.rating,
                            columnComment: movieModel.comment,
                            columnDateTime: movieModel.dateTime.toString().split(' ')[0],
                          });

                          Get.back();
                        },
                        icon: Icon(
                          Icons.check,
                          color: Get.isDarkMode ? Colors.white : Colors.black,
                          size: deviceWidth / 12,
                        ),
                        splashRadius: deviceWidth / 18,
                      ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: Obx(
                  () => (addPageController.pageNumber.value == 1)
                      ? SearchWidget(
                          movieController: movieController,
                          textController: textController,
                          addPageController: addPageController,
                          textFocus: textFocus,
                        )
                      : AddWidget(
                          movieController: movieController,
                          textController: textController,
                          textFocus: textFocus,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void saveToListStar(MovieModel movieModel, BasicController basicController) {
  Map<double, int> temp = {5 : 0, 4.5 : 1, 4 : 2, 3.5 : 3, 3 : 4, 2.5 : 5,
    2 : 6, 1.5 : 7, 1 : 8, 0.5 : 9};
  int index = temp[movieModel.rating]!;
  double rating = movieModel.rating;
  int j = 0;
  if(basicController.savedMoviesStar[index][rating].isEmpty){
    basicController.savedMoviesStar[index][rating].add(movieModel);
  } else {
    for(MovieModel i in basicController.savedMoviesStar[index][rating]) {
      if(i.dateTime.microsecondsSinceEpoch > movieModel.dateTime.microsecondsSinceEpoch){
        basicController.savedMoviesStar[index][rating].insert(j, movieModel);
        break;
      } else if (basicController.savedMoviesStar[index][rating].length == j + 1) {
        basicController.savedMoviesStar[index][rating].add(movieModel);
        break;
      }
      j++;
    }
  }
}