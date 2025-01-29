import 'package:flutter/material.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

class ElevatedButtonSubscribe extends StatelessWidget {
  final PodcastEntity podcast;
  const ElevatedButtonSubscribe({super.key, required this.podcast});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(podcast.subscribed ? "Unsubscribed" : "Subscribe"),
    );
  }
}
