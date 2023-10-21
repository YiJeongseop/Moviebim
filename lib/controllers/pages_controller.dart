import 'package:get/get.dart';
import '../models/movie_model.dart';

class PagesController extends GetxController{
  RxInt pageNumber = 1.obs;
  RxBool sortedByStar = false.obs;
  RxList movieList = [].obs;
  RxList movieListSortedByStar = [].obs;

  @override
  void onInit() {
    // TODO: movieList, movieListSortedByStar
    super.onInit();
  }
}