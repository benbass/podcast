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
        Row(
          children: [
            Icon(episode.favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
            Icon(
              episode.read == true
                  ? Icons.check_circle_outline_rounded
                  : null,
              //color: Colors.black,
            ),
          ],
        ),
      ],
    );
  }
}