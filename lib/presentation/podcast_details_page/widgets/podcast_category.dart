import 'package:flutter/material.dart';

class PodcastCategory extends StatelessWidget {
  final String value;
  const PodcastCategory({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
