import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../controllers/movie_controller.dart';
import '../controllers/text_controller.dart';
import '../services/tmdb_service.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({Key? key}) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TmdbService _tmdbService = TmdbService();
  final TextController textController = Get.put(TextController());
  final MovieController movieController = Get.put(MovieController());

  @override
  void dispose() {
    textController.dispose();
    movieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Get.isDarkMode ? Colors.white.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          margin: const EdgeInsets.only(left: 15, right: 15),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.enterATitle,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.all(8),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark
                  ),
                  onChanged: (value) => textController.updateTitle(value),
                  textInputAction: TextInputAction.go,
                  onSubmitted: (value) async {
                    try {
                      final searchResult = await _tmdbService.searchMovies(value);
                      movieController.movies.value = searchResult['results'];
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.errorMessage),
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.search,
                  color: Get.isDarkMode ? Colors.white.withOpacity(0.5) : Colors.grey,
                  size: 25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: Get.isDarkMode ? Colors.white70 : Colors.black12),
        Expanded(
          child: Obx(
            () => GridView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                mainAxisExtent: (MediaQuery.of(context).size.width / 2.5) * 1.95,
              ),
              itemCount: movieController.movies.length,
              itemBuilder: (context, index) {
                final movie = movieController.movies[index];
                return Card(
                  color: Get.isDarkMode ? Colors.grey.withOpacity(0.47): Colors.white.withOpacity(0.95),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {},
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
                            height: (MediaQuery.of(context).size.width / 2.5) * 1.5,
                            width: MediaQuery.of(context).size.width / 2.5,
                            fit: BoxFit.fill,
                          ),
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5, right: 5),
                                  child: Text(
                                    movie['title'], 
                                    style: TextStyle(color: Theme.of(context).primaryColorDark),
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
