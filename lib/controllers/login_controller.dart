import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LoginController extends GetxController{
  RxBool isLogined = false.obs;

  @override
  void onInit() {
    if(FirebaseAuth.instance.currentUser != null){
      isLogined.value = true;
    }
    super.onInit();
  }
}