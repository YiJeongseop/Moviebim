import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controllers/add_page_controller.dart';
import '../controllers/movie_controller.dart';
import '../controllers/text_controller.dart';
import '../services/tmdb_service.dart';

class SearchWidget extends StatelessWidget {
  SearchWidget({Key? key,
    required this.movieController, required this.textController,
    required this.addPageController, required this.textFocus})
      : super(key: key);

  final TmdbService _tmdbService = TmdbService();
  final MovieController movieController;
  final TextController textController;
  final AddPageController addPageController;
  final FocusNode textFocus;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    List<int> errorList = [];
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.surface,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          margin: const EdgeInsets.only(left: 15, right: 15),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: textFocus,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.enterATitle,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.all(8),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onChanged: (value) => textController.updateTitle(value),
                  textInputAction: TextInputAction.go,
                  onSubmitted: (value) async {
                    try {
                      final searchResult = await _tmdbService.searchMovies(value);
                      movieController.movies.value = searchResult['results'];
                      if(movieController.movies.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.noResult,
                              style: TextStyle(color: Theme.of(context).colorScheme.background),
                            ),
                            duration: const Duration(seconds: 5),
                            showCloseIcon: true,
                            closeIconColor: Theme.of(context).colorScheme.background,
                            backgroundColor: Theme.of(context).colorScheme.onBackground,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.errorMessage,
                            style: TextStyle(color: Theme.of(context).colorScheme.background),
                          ),
                          duration: const Duration(seconds: 5),
                          showCloseIcon: true,
                          closeIconColor: Theme.of(context).colorScheme.background,
                          backgroundColor: Theme.of(context).colorScheme.onBackground,
                        ),
                      );
                    }
                  },
                ),
              ),
              Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onError,
                size: deviceWidth / 15,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: Theme.of(context).dividerColor),
        Expanded(
          child: Obx(
            () => GridView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                mainAxisExtent: (deviceWidth / 2.5) * 1.95,
              ),
              itemCount: movieController.movies.length,
              itemBuilder: (context, index) {
                final movie = movieController.movies[index];
                return Card(
                  color: Theme.of(context).cardColor,
                  elevation: 2.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      if(!errorList.contains(index)){
                        try{
                          movieController.movieRuntime.value = 0;
                          movieController.movieRuntime.value = await _tmdbService.fetchRuntime(movie['id']);
                          if(movieController.movieRuntime.value == 0){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context)!.errorMessage,
                                  style: TextStyle(color: Theme.of(context).colorScheme.background),
                                ),
                                duration: const Duration(seconds: 5),
                                showCloseIcon: true,
                                closeIconColor: Theme.of(context).colorScheme.background,
                                backgroundColor: Theme.of(context).colorScheme.onBackground,
                              ),
                            );
                            return;
                          }
                          movieController.selectedMovie.add(movie);
                          addPageController.pageNumber.value = 2;
                        } catch(e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.errorMessage,
                                style: TextStyle(color: Theme.of(context).colorScheme.background),
                              ),
                              duration: const Duration(seconds: 5),
                              showCloseIcon: true,
                              closeIconColor: Theme.of(context).colorScheme.background,
                              backgroundColor: Theme.of(context).colorScheme.onBackground,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.transparent,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 5),
                          Image.network(
                            'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                            height: (deviceWidth / 2.5) * 1.5,
                            width: deviceWidth / 2.5,
                            fit: BoxFit.fill,
                            errorBuilder: (context, object, stackTrace){
                              errorList.add(index);
                              return SizedBox(
                                height: (deviceWidth / 2.5) * 1.5,
                                width: deviceWidth / 2.5,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Theme.of(context).colorScheme.error,
                                  size: deviceWidth * 0.25,
                                ),
                              );
                            },
                          ),
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5, right: 5),
                                  child: Text(
                                    movie['title'],
                                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
