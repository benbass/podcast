import 'package:flutter/material.dart';

BoxDecoration buildBoxDecoration(BuildContext context) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(10.0),
    color: Theme.of(context).colorScheme.primaryContainer,
    boxShadow: const [
      BoxShadow(
        color: Colors.black,
        blurRadius: 5.0,
        offset: Offset(0, 6),
        spreadRadius: 1.0,
      ),
    ],
  );
}