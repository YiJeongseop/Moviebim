import 'package:get/get.dart';

class TextController extends GetxController{
  var movieTitle = ''.obs;

  void updateTitle(String title){
    movieTitle.value = title;
  }
}