import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/movie_model.dart';
import '../controllers/movie_controller.dart';
import '../controllers/pages_controller.dart';
import '../controllers/text_controller.dart';
import '../controllers/day_controller.dart';
import '../widgets/search_widget.dart';
import '../widgets/add_widget.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final DayController dayController = Get.arguments;
  final TextController textController = Get.put(TextController());
  final MovieController movieController = Get.put(MovieController());
  final PagesController pagesController = Get.put(PagesController());
  FocusNode textFocus = FocusNode();

  @override
  void dispose() {
    textController.dispose();
    movieController.dispose();
    pagesController.dispose();
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
              () => pagesController.pageNumber.value == 2
                  ? IconButton(
                      onPressed: () {
                        movieController.selectedMovie.clear();
                        pagesController.pageNumber.value = 1;
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
                () => (pagesController.pageNumber.value == 1)
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
                          final dateExist = dayController.savedMovies.any((map) => map.containsKey(dayController.selectedDate.value));
                          if(dateExist){
                            for(int i = 0; i < dayController.savedMovies.length; i++){
                              if(dayController.savedMovies[i].containsKey(dayController.selectedDate.value)){
                                dayController.savedMovies[i][dayController.selectedDate.value].add(MovieModel(
                                  title: movieController.selectedMovie[0]['title'],
                                  posterPath: 'https://image.tmdb.org/t/p/w500${movieController.selectedMovie[0]['poster_path']}',
                                  rating: movieController.movieRating.value,
                                  comment: textController.movieComment.value,
                                  dateTime: dayController.selectedDate.value,
                                ));
                                break;
                              }
                            }
                          } else if (dayController.savedMovies.isEmpty) {
                            dayController.savedMovies.add(
                              {
                                dayController.selectedDate.value: [MovieModel(
                                  title: movieController.selectedMovie[0]['title'],
                                  posterPath: 'https://image.tmdb.org/t/p/w500${movieController.selectedMovie[0]['poster_path']}',
                                  rating: movieController.movieRating.value,
                                  comment: textController.movieComment.value,
                                  dateTime: dayController.selectedDate.value,
                                )]
                              },
                            );
                          }
                          else {
                            int i = 0;
                            for (Map<DateTime, dynamic> map in dayController.savedMovies){
                              DateTime temp = map.keys.toList()[0];
                              if(temp.microsecondsSinceEpoch > dayController.selectedDate.value.microsecondsSinceEpoch){
                                dayController.savedMovies.insert(i,
                                  {
                                    dayController.selectedDate.value: [MovieModel(
                                      title: movieController.selectedMovie[0]['title'],
                                      posterPath: 'https://image.tmdb.org/t/p/w500${movieController.selectedMovie[0]['poster_path']}',
                                      rating: movieController.movieRating.value,
                                      comment: textController.movieComment.value,
                                      dateTime: dayController.selectedDate.value,
                                    )]
                                  },
                                );
                                break;
                              }
                              i++;
                              if(i == dayController.savedMovies.length){
                                dayController.savedMovies.add(
                                  {
                                    dayController.selectedDate.value: [MovieModel(
                                      title: movieController.selectedMovie[0]['title'],
                                      posterPath: 'https://image.tmdb.org/t/p/w500${movieController.selectedMovie[0]['poster_path']}',
                                      rating: movieController.movieRating.value,
                                      comment: textController.movieComment.value,
                                      dateTime: dayController.selectedDate.value,
                                    )]
                                  },
                                );
                                break;
                              }
                            }
                          }
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
                  () => (pagesController.pageNumber.value == 1)
                      ? SearchWidget(
                          movieController: movieController,
                          textController: textController,
                          pagesController: pagesController,
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
