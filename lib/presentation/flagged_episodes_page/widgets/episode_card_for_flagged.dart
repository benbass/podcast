import 'package:flutter/material.dart';
import 'package:podcast/presentation/custom_widgets/episode_card.dart';

import '../../../domain/entities/episode_entity.dart';
import '../../../domain/entities/podcast_entity.dart';

class EpisodeCardForFlagged extends StatelessWidget {
  final EpisodeEntity episode;
  final PodcastEntity podcast;
  final String flag;
  const EpisodeCardForFlagged({
    super.key,
    required this.episode,
    required this.podcast,
    required this.flag,
  });

  @override
  Widget build(BuildContext context) {
    return EpisodeCard(episode: episode, podcast: podcast, flag: flag);
  }
}