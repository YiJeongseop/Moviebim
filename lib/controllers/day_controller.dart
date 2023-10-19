import 'package:get/get.dart';

class DayController extends GetxController{
  Rx<DateTime> selectedDate = DateTime.now().obs;
  RxList<dynamic> savedMovies = [].obs;

  @override
  void onInit() {
    // TODO: fetch savedMovies
    super.onInit();
  }
}