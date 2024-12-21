
import 'package:flutter/material.dart';

class Categories extends StatelessWidget {
  final String value;
  const Categories({
    super.key, required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}