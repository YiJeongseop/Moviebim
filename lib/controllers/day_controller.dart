import 'package:get/get.dart';

class DayController extends GetxController{
  Rx<DateTime> selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).obs;
  RxList<dynamic> savedMovies = [].obs;

  @override
  void onInit() {
    print("day_controller.dart selectedDate : $selectedDate");
    // TODO: fetch savedMovies
    super.onInit();
  }
}