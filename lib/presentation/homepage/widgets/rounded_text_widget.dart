import 'package:flutter/material.dart';

class RoundedTextWidget extends StatelessWidget {
  final String text;
  final double paddingValue;

  const RoundedTextWidget({
    super.key,
    required this.text,
    this.paddingValue = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: themeData.colorScheme.onPrimary//backgroundColor,
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.all(paddingValue), // Dynamisches Padding
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: themeData.colorScheme.primaryContainer,
            fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
