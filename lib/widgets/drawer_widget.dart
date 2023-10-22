import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: deviceWidth / 2,
      child: Drawer(
        backgroundColor: Theme.of(context).primaryColor,
        child: Column(
          children: [

          ],
        ),
      ),
    );
  }
}
