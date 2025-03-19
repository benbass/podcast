import 'package:flutter/material.dart';

Widget buildFailureWidget({required String message}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 60,
      ),
      Padding(
        padding: const EdgeInsets.only(
            top: 16, left: 16, right: 16),
        child: Text(message),
      ),
    ],
  );
}