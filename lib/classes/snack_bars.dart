import 'package:flutter/material.dart';

class SnackBars {
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    bool persist = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message),
        duration: const Duration(seconds: 2),
        persist: persist,
      ),
    );
  }

  static void showInformativeSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blueAccent,
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
