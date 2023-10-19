import 'package:get/get.dart';

class TextController extends GetxController{
  var movieTitle = ''.obs;
  var movieComment = ''.obs;

  void updateTitle(String title){
    movieTitle.value = title;
  }

  void updateComment(String comment){
    movieComment.value = comment;
  }
}