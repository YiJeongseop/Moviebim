import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/movie_model.dart';
import '../controllers/movie_controller.dart';
import '../controllers/text_controller.dart';
import '../controllers/basic_controller.dart';
import 'add_screen.dart';
import 'home_screen.dart';

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
          backgroundColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[50],
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[50],
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back,
                color: Get.isDarkMode ? Colors.grey[300] : Colors.black.withOpacity(0.7),
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

                  deleteListStar(movieController.selectedMovie[0], basicController);
                  saveToListStar(movieModel, basicController);
                  dbHelper.updateData(movieModel.rating, movieModel.comment, movieController.selectedMovie[0]);

                  Get.back();
                },
                icon: Icon(
                  Icons.check,
                  color: Get.isDarkMode ? Colors.grey[300] : Colors.black.withOpacity(0.7),
                  size: (deviceWidth > 600) ? deviceWidth / 23 : deviceWidth / 12,
                ),
                splashRadius: (deviceWidth > 600) ? deviceWidth / 45 : deviceWidth / 18,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Get.isDarkMode ? Colors.black.withOpacity(0.5): Colors.grey.withOpacity(0.5),
                        width: 2,
                      ),
                      color: Get.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey[50],
                    ),
                    padding: const EdgeInsets.all(3.0),
                    child: Image.network(
                      movieController.selectedMovie[0].posterPath,
                      height: (deviceWidth / 2.2) * 1.5,
                      width: deviceWidth / 2.2,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Divider(color: Theme.of(context).dividerColor, thickness: 1.1),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: RatingBar.builder(
                    initialRating: movieController.selectedMovie[0].rating,
                    minRating: 0.5,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      movieController.movieRating.value = rating;
                    },
                  ),
                ),
                Divider(color: Theme.of(context).dividerColor, thickness: 1.1),
                const SizedBox(height: 10),
                Container(
                  width: deviceWidth * 0.8,
                  height: MediaQuery.of(context).size.height * 0.27,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Get.isDarkMode ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.9),
                    ),
                    color: Get.isDarkMode ? Colors.black.withOpacity(0.24) : Colors.white,
                  ),
                  child: TextField(
                    controller: textEditingController,
                    maxLines: null,
                    focusNode: textFocus,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.leaveAComment,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                    ),
                    style: TextStyle(
                      color: Get.isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.9),
                      fontSize: deviceWidth * 0.045
                    ),
                    onChanged: (value) => textController.updateComment(value),
                    textInputAction: TextInputAction.go,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
