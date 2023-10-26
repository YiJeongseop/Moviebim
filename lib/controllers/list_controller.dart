import 'package:get/get.dart';

class ListController extends GetxController{
  RxBool sortedByStar = false.obs;
  RxList movieList = [].obs;
  RxList movieListSortedByStar = [].obs;
}