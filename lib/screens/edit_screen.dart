import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/movie_controller.dart';
import '../controllers/text_controller.dart';
import '../controllers/basic_controller.dart';
import '../models/movie_model.dart';
import 'add_screen.dart';
import 'calendar_screen.dart';
import 'home_screen.dart';
import '../widgets/detail_widget.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final BasicController basicController = Get.arguments[0];
  final int listIndex = Get.arguments[1];
  final int index = Get.arguments[2];
  final TextController textController = Get.put(TextController());
  final MovieController movieController = Get.put(MovieController());
  FocusNode textFocus = FocusNode();
  late final TextEditingController textEditingController;

  @override
  void dispose() {
    textController.dispose();
    movieController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    movieController.selectedMovie.add(MovieModel(
      title: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].title,
      posterPath: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].posterPath,
      rating: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].rating,
      comment: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].comment,
      dateTime: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].dateTime,
      runtime: basicController.savedMovies[listIndex][basicController.selectedDate.value][index].runtime,
    ));
    movieController.movieRating.value = basicController.savedMovies[listIndex][basicController.selectedDate.value][index].rating;
    textController.movieComment.value = basicController.savedMovies[listIndex][basicController.selectedDate.value][index].comment;
    textEditingController = TextEditingController(text: movieController.selectedMovie[0].comment);
    super.initState();
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
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.onBackground,
                size: (deviceWidth > 600) ? deviceWidth / 23 : deviceWidth / 12,
              ),
              splashRadius: (deviceWidth > 600) ? deviceWidth / 45 : deviceWidth / 18,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  final movieModel = MovieModel(
                    title: movieController.selectedMovie[0].title,
                    posterPath: movieController.selectedMovie[0].posterPath,
                    rating: movieController.movieRating.value,
                    comment: textController.movieComment.value,
                    dateTime: movieController.selectedMovie[0].dateTime,
                    runtime: movieController.selectedMovie[0].runtime,
                  );
                  basicController.savedMovies[listIndex][basicController.selectedDate.value].removeAt(index);
                  var temp = basicController.savedMovies[listIndex];
                  basicController.savedMovies.removeAt(listIndex);
                  basicController.savedMovies.insert(listIndex, temp);
                  basicController.savedMovies[listIndex][basicController.selectedDate.value].add(movieModel);

                  deleteListOfStar(movieController.selectedMovie[0], basicController);
                  saveToListOfStar(movieModel, basicController);
                  dbHelper.updateData(movieModel.rating, movieModel.comment, movieController.selectedMovie[0]);

                  Get.back();
                },
                icon: Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.onBackground,
                  size: (deviceWidth > 600) ? deviceWidth / 23 : deviceWidth / 12,
                ),
                splashRadius: (deviceWidth > 600) ? deviceWidth / 45 : deviceWidth / 18,
              ),
            ],
          ),
          body: DetailWidget(
            movieController: movieController,
            textController: textController,
            textFocus: textFocus,
            textEditingController: textEditingController,
            posterPath: movieController.selectedMovie[0].posterPath,
            initialRating: movieController.selectedMovie[0].rating,
          ),
        ),
      ),
    );
  }
}
