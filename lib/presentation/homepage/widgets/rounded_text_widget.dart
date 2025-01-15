import 'package:flutter/material.dart';

class RoundedTextWidget extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final double fontSize;
  final double paddingValue;

  const RoundedTextWidget({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0xFF3B1734),
    this.fontSize = 13.0,
    this.paddingValue = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.all(paddingValue), // Dynamisches Padding
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}