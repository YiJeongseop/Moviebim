import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/movie_model.dart';
import '../controllers/movie_controller.dart';
import '../controllers/pages_controller.dart';
import '../controllers/text_controller.dart';
import '../controllers/day_controller.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final DayController dayController = Get.arguments[0];
  final int listIndex = Get.arguments[1];
  final String dateStr = Get.arguments[2];
  final int index = Get.arguments[3];
  final TextController textController = Get.put(TextController());
  final MovieController movieController = Get.put(MovieController());
  final PagesController pagesController = Get.put(PagesController());
  FocusNode textFocus = FocusNode();
  late final TextEditingController textEditingController;

  @override
  void dispose() {
    textController.dispose();
    movieController.dispose();
    pagesController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    movieController.selectedMovie.add(MovieModel(
        title: dayController.savedMovies[listIndex][dateStr][index].title,
        posterPath: dayController.savedMovies[listIndex][dateStr][index].posterPath,
        rating: dayController.savedMovies[listIndex][dateStr][index].rating,
        comment: dayController.savedMovies[listIndex][dateStr][index].comment));
    movieController.movieRating.value = dayController.savedMovies[listIndex][dateStr][index].rating;
    textController.movieComment.value = dayController.savedMovies[listIndex][dateStr][index].comment;
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
          backgroundColor: Theme.of(context).primaryColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back,
                color: Get.isDarkMode ? Colors.white : Colors.black,
                size: deviceWidth / 12,
              ),
              splashRadius: deviceWidth / 18,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  dayController.savedMovies[listIndex][dateStr].removeAt(index);
                  var temp = dayController.savedMovies[listIndex];
                  dayController.savedMovies.removeAt(listIndex);
                  dayController.savedMovies.add(temp);
                  dayController.savedMovies[dayController.savedMovies.length - 1][dateStr].add(
                    MovieModel(
                        title: movieController.selectedMovie[0].title,
                        posterPath: movieController.selectedMovie[0].posterPath,
                        rating: movieController.movieRating.value,
                        comment: textController.movieComment.value,
                    )
                  );
                  Get.back();
                },
                icon: Icon(
                  Icons.check,
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                  size: deviceWidth / 12,
                ),
                splashRadius: deviceWidth / 18,
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
                        color: Get.isDarkMode ? Colors.white54: Colors.black12,
                        width: 2,
                      ),
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
                Divider(color: Get.isDarkMode ? Colors.white70 : Colors.black12),
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
                Divider(color: Get.isDarkMode ? Colors.white70 : Colors.black12),
                const SizedBox(height: 10),
                TextField(
                  controller: textEditingController,
                  maxLines: null,
                  focusNode: textFocus,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.leaveAComment,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.only(top: 5, left: 24, right: 10),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: deviceWidth * 0.05
                  ),
                  onChanged: (value) => textController.updateComment(value),
                  textInputAction: TextInputAction.go,
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
