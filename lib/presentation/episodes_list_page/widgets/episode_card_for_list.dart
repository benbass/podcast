import 'package:flutter/material.dart';
import 'package:podcast/presentation/custom_widgets/episode_card.dart';

import '../../../domain/entities/episode_entity.dart';
import '../../../domain/entities/podcast_entity.dart';

class EpisodeCardForList extends StatelessWidget {
  final List<EpisodeEntity> episodes;
  final EpisodeEntity episode;
  final PodcastEntity podcast;
  const EpisodeCardForList({
    super.key,
    required this.episodes,
    required this.episode,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    return EpisodeCard(episodes: episodes, episode: episode, podcast: podcast);
  }
}
