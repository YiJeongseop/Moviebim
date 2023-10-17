import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/search_widget.dart';
import '../controllers/day_controller.dart';

class AddScreen extends StatelessWidget {
  AddScreen({Key? key}) : super(key: key);

  final DayController dayController = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.close,
                color: Get.isDarkMode ? Colors.white : Colors.black,
                size: MediaQuery.of(context).size.width / 12,
              ),
              splashRadius: MediaQuery.of(context).size.width / 18,
            ),
          ],
        ),
        body: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Expanded(child: SearchWidget()),
          ],
        ),
      ),
    );
  }
}
