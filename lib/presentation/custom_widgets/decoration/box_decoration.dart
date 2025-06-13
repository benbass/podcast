import 'package:flutter/material.dart';

BoxDecoration buildBoxDecoration(BuildContext context) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(10.0),
    color: Colors.white10,
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 5.0,
        offset: Offset(0, 6),
        spreadRadius: 1.0,
      ),
    ],
  );
}