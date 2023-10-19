import 'package:get/get.dart';

class MovieController extends GetxController{
  RxList<dynamic> movies = [].obs;
  RxList<dynamic> selectedMovie = [].obs;
  RxDouble movieRating = 3.0.obs;
}