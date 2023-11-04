import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text){
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.background,
          ),
        ),
        showCloseIcon: true,
        closeIconColor: Theme.of(context).colorScheme.background,
        backgroundColor: Theme.of(context).colorScheme.onBackground,
        duration: const Duration(seconds: 5),
      )
  );
}