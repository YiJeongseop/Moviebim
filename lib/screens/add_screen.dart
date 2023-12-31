import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/add_page_controller.dart';
import '../controllers/movie_controller.dart';
import '../controllers/text_controller.dart';
import '../controllers/basic_controller.dart';
import '../models/movie_model.dart';
import 'home_screen.dart';
import '../utilities/db_helper.dart';
import '../widgets/search_widget.dart';
import '../widgets/detail_widget.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final BasicController basicController = Get.arguments;
  final TextController textController = Get.put(TextController());
  final MovieController movieController = Get.put(MovieController());
  final AddPageController addPageController = Get.put(AddPageController());
  FocusNode textFocus = FocusNode();

  _saveRuntime(int value) async {
    SharedPreferences pref = await _prefs;
    pref.setInt('runtime', value);
  }

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
          backgroundColor: Theme.of(context).colorScheme.background,
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
                        color: Theme.of(context).colorScheme.onBackground,
                        size: (deviceWidth > 600) ? deviceWidth / 23 : deviceWidth / 12,
                      ),
                      splashRadius: (deviceWidth > 600) ? deviceWidth / 45 : deviceWidth / 18,
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
                          color: Theme.of(context).colorScheme.onBackground,
                          size: (deviceWidth > 600) ? deviceWidth / 23 : deviceWidth / 12,
                        ),
                        splashRadius: (deviceWidth > 600) ? deviceWidth / 45 : deviceWidth / 18,
                      )
                    : IconButton(
                        onPressed: () {
                          final movieModel = MovieModel(
                            title: movieController.selectedMovie[0]['title'],
                            posterPath: 'https://image.tmdb.org/t/p/w500${movieController.selectedMovie[0]['poster_path']}',
                            rating: movieController.movieRating.value,
                            comment: textController.movieComment.value,
                            dateTime: basicController.selectedDate.value,
                            runtime: movieController.movieRuntime.value,
                          );
                          final dateExist = basicController.savedMovies.any((map) => map.containsKey(basicController.selectedDate.value));
                          if(dateExist){
                            for(int i = 0; i < basicController.savedMovies.length; i++){
                              if(basicController.savedMovies[i].containsKey(basicController.selectedDate.value)){
                                basicController.savedMovies[i][basicController.selectedDate.value].add(movieModel);

                                basicController.savedMovies.add(
                                  {
                                    DateTime(2023, 9, 30): [movieModel]
                                  }
                                );
                                basicController.savedMovies.removeAt(basicController.savedMovies.length - 1);

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
                          saveToListOfStar(movieModel, basicController);

                          dbHelper.insertData({
                            columnTitle: movieModel.title,
                            columnPosterPath: movieModel.posterPath,
                            columnRating: movieModel.rating,
                            columnComment: movieModel.comment,
                            columnDateTime: movieModel.dateTime.toString().split(' ')[0],
                            columnRuntime: movieModel.runtime
                          });

                          basicController.entireRuntime.value += movieModel.runtime;
                          _saveRuntime(basicController.entireRuntime.value);

                          Get.back();
                        },
                        icon: Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.onBackground,
                          size: (deviceWidth > 600) ? deviceWidth / 23 : deviceWidth / 12,
                        ),
                        splashRadius: (deviceWidth > 600) ? deviceWidth / 45 : deviceWidth / 18,
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
                      : DetailWidget(
                          movieController: movieController,
                          textController: textController,
                          textFocus: textFocus,
                          textEditingController: null,
                          posterPath: 'https://image.tmdb.org/t/p/w500${movieController.selectedMovie[0]['poster_path']}',
                          initialRating: 3,
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

void saveToListOfStar(MovieModel movieModel, BasicController basicController) {
  int index = starToIndex[movieModel.rating]!;
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