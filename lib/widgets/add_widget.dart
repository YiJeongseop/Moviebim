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
                  color: Get.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.5),
                  width: 2,
                ),
                color: Get.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white,
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
          Divider(color: Theme.of(context).dividerColor, thickness: 1.1),
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
          Divider(color: Theme.of(context).dividerColor, thickness: 1.1),
          const SizedBox(height: 10),
          Container(
            width: deviceWidth * 0.8,
            height: MediaQuery.of(context).size.height * 0.27,
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Colors.black.withOpacity(0.22) : Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.black.withOpacity(0.4),
              )
            ),
            child: TextField(
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
                color: Theme.of(context).primaryColorDark,
                fontSize: deviceWidth * 0.045
              ),
              onChanged: (value) => textController.updateComment(value),
              textInputAction: TextInputAction.go,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
        ],
      ),
    );
  }
}
