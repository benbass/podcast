import 'package:flutter/material.dart';

import '../../../domain/entities/episode_entity.dart';
import '../../../helpers/core/format_duration.dart';
import '../../../helpers/core/format_pubdate_string.dart';

class EpisodeMetadata extends StatelessWidget {
  const EpisodeMetadata({
    super.key,
    required this.episode,
  });

  final EpisodeEntity episode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatTimestamp(episode.datePublished),
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          episode.duration! == 0
              ? ""
              : formatIntDuration(episode.duration!),
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Icon(
          episode.read == true
              ? Icons.check_circle_outline_rounded
              : Icons.remove_circle_outline_rounded,
          //color: Colors.black,
        ),
      ],
    );
  }
}