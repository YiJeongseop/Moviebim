import 'package:get/get.dart';

class BasicController extends GetxController{
  Rx<DateTime> selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).obs;
  RxList<dynamic> savedMovies = [].obs;
  RxList<dynamic> savedMoviesStar = [{5 : []}, {4.5 : []}, {4 : []}, {3.5 : []}, {3 : []},
    {2.5 : []}, {2 : []}, {1.5 : []}, {1 : []}, {0.5 : []}].obs;
}