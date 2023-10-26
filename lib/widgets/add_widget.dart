import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controllers/movie_controller.dart';
import '../controllers/text_controller.dart';

class AddWidget extends StatelessWidget {
  const AddWidget({Key? key,
    required this.movieController, required this.textController, required this.textFocus})
      : super(key: key);

  final MovieController movieController;
  final TextController textController;
  final FocusNode textFocus;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final movie = movieController.selectedMovie;
    return SingleChildScrollView(
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
                'https://image.tmdb.org/t/p/w500${movie[0]['poster_path']}',
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
              initialRating: 3,
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
    );
  }
}
