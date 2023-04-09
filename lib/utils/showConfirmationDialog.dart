import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    actions: [
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context, true);
        },
        child: const Text("Yes"),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context, false);
        },
        child: const Text("No"),
      )
    ],
    content: Text("Are you sure you want to proceed?"),
  );

  return showDialog<bool>(
    // barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
